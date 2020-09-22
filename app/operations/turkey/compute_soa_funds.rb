module Turkey
  class ComputeSoaFunds
    attr_reader :branch, :from, :to, :accounts

    def initialize(branch:, from:, to:)
      @branch   = branch
      @from     = from
      @to       = to

      @accounts = Settings.default_member_accounts.map{ |o|
                    [o[:account_subtype].parameterize.underscore, o[:account_subtype]]
                  }.to_h

      @account_subtypes = @accounts.map{ |o| "'#{o[1]}'" }.join(",")
    end

    def run
      sums = accounts.map do |key, subtype|
        <<-EOS
          SUM(CASE WHEN account_subtype = '#{subtype}' AND at.transaction_type = 'withdraw' THEN amount ELSE 0 END)
            OVER(PARTITION BY ma.member_id ORDER BY transacted_at)
            AS #{key}_debit,
          SUM(CASE WHEN account_subtype = '#{subtype}' AND at.transaction_type = 'deposit' THEN amount ELSE 0 END)
            OVER(PARTITION BY ma.member_id ORDER BY transacted_at)
            AS #{key}_credit,
        EOS
      end

      ReadOnlyDataStore.connection.execute(<<-EOS).to_a
        SELECT
          ma.account_type,
          ma.account_subtype,
          m.id as member_id,
          m.middle_name,
          m.last_name,
          m.first_name,
          m.identification_number AS member_identification_number,
          m.status AS member_status,
          c.id AS center_id,
          c.name AS center_name,
          #{sums.join}
          at.transaction_type,
          at.amount,
          at.transacted_at,
          u.id AS officer_id,
          u.first_name AS officer_first_name,
          u.last_name AS officer_last_name,
          u.identification_number AS officer_identification_number
        FROM account_transactions at
          INNER JOIN member_accounts ma ON ma.id = at.subsidiary_id AND ma.account_subtype IN (#{@account_subtypes})
          INNER JOIN members m ON m.id = ma.member_id
          INNER JOIN centers c ON c.id = m.center_id
          INNER JOIN users u ON u.id = c.user_id
        WHERE at.transacted_at BETWEEN '#{from}' AND '#{to}'
          AND m.branch_id = '#{branch.id}'
          AND m.status IN ('active', 'resigned')
        ORDER BY m.last_name ASC, m.first_name ASC, at.transacted_at ASC, ma.account_type ASC, ma.account_subtype ASC
      EOS
    end
  end
end
