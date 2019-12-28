module Turkey
  class ComputeSoaFunds
    attr_reader :branch, :from, :to, :accounts

    def initialize(branch:, from:, to:)
      @branch = branch
      @from = from
      @to = to
      @accounts = MemberAccount
        .pluck(:account_subtype).uniq
        .map { |subtype| [subtype.parameterize.underscore, subtype] }
        .to_h
    end

    def run
      sums = accounts.map do |key, subtype|
        <<-EOS
          SUM(CASE WHEN account_subtype = '#{subtype}' AND at.transaction_type = 'withdraw' THEN amount ELSE 0 END)
            OVER(PARTITION BY member_id ORDER BY transacted_at)
            AS #{key}_debit,
          SUM(CASE WHEN account_subtype = '#{subtype}' AND at.transaction_type = 'deposit' THEN amount ELSE 0 END)
            OVER(PARTITION BY member_id ORDER BY transacted_at)
            AS #{key}_credit,
        EOS
      end

      ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT
          ma.account_type,
          ma.account_subtype,
          m.id as member_id,
          m.last_name,
          m.first_name,
          #{sums.join}
          at.transaction_type,
          at.amount,
          at.transacted_at
        FROM account_transactions at
          INNER JOIN member_accounts ma ON ma.id = at.subsidiary_id
          INNER JOIN members m ON m.id = ma.member_id
        WHERE at.transacted_at BETWEEN '#{from}' AND '#{to}'
          AND m.branch_id = '#{branch.id}'
          AND m.status IN ('active', 'resigned')
        ORDER BY m.last_name ASC, m.first_name ASC, at.transacted_at DESC, ma.account_type ASC, ma.account_subtype ASC
      EOS
    end
  end
end
