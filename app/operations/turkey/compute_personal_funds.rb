module Turkey
  class ComputePersonalFunds
    attr_reader :branch, :as_of, :accounts

    def initialize(branch:, as_of: Date.today)
      @branch = branch
      @as_of = as_of
      @accounts = MemberAccount
        .pluck(:account_subtype).uniq
        .map { |subtype| [subtype.parameterize.underscore, subtype] }
        .to_h
    end

    def run
      ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT DISTINCT ON (m.last_name, m.first_name, m.id, ma.account_subtype)
          at.data ->> 'ending_balance' AS ending_balance,
          at.transacted_at,
          at.id AS account_transaction_id,
          ma.id AS member_account_id,
          ma.account_type,
          ma.account_subtype,
          m.identification_number AS member_identification_number,
          m.last_name,
          m.first_name,
          m.middle_name,
          m.status AS member_status,
          m.id AS member_id,
          c.id AS center_id,
          c.name AS center_name,
          u.id AS officer_id,
          u.first_name AS officer_first_name,
          u.last_name AS officer_last_name,
          u.identification_number AS officer_identification_number
        FROM account_transactions at
          INNER JOIN member_accounts ma ON ma.id = at.subsidiary_id
          INNER JOIN members m ON m.id = ma.member_id
          INNER JOIN centers c ON c.id = m.center_id
          INNER JOIN users u ON u.id = c.user_id
        WHERE DATE(at.transacted_at) <= DATE('#{as_of}')
          AND m.branch_id = '#{branch.id}'
          AND at.transaction_type IN ('deposit', 'withdraw')
          AND at.status IN ('approved')
        ORDER BY m.last_name, m.first_name, m.id, ma.account_subtype ASC, at.transacted_at DESC, at.updated_at DESC
      EOS
    end
  end
end
