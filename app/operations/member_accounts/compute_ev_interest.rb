module MemberAccounts
  class ComputeEvInterest
    attr_accessor :data
    def initialize(config:)
      @config               = config
      @start_date           = @config[:start_date]
      @end_date             = @config[:end_date]

      if @start_date.nil?
        @start_date         = "2019-01-01".to_date
      end

      if @end_date.nil?
        @end_date           = Date.today
      end

      @branch               = @config[:branch]
      @x_interest           = 0.000833333333333
    end

    def execute!
      query!

      @result.to_a.map{ |o|

        transaction_id     = o.fetch("transaction_id")
        member_account_id  = o.fetch("member_account_id")
        transacted_at      = o.fetch("transacted_at")
        balance            = o.fetch("balance")
        
        interest_amount    = ((balance.to_f / 2) * @x_interest).round(2)
              
        interest = Interest.new(
                                            member_account_id: member_account_id,
                                            account_transaction_id: transaction_id,
                                            month_of_year_date: transacted_at.to_date,
                                            interest_amount: interest_amount,
                                            interest_type: 'ev_interest'
                                            )

        interest.save!
      }
    end

    def query!
      @result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT DISTINCT ON(account_transactions.id)
                    account_transactions.id AS transaction_id,
                    account_transactions.transacted_at,
                    COALESCE(account_transactions.data->>'ending_balance', '0.00')::float AS balance,
                    member_accounts.id AS member_account_id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    COALESCE(member_accounts.balance, '0.00')::float AS ma_balance,
                    members.data->>'recognition_date' AS recognition_date,
                    members.id AS member_id,
                    members.member_type,
                    members.status,
                    members.insurance_status,
                    members.insurance_date_resigned
                  FROM
                    account_transactions
                  LEFT JOIN
                    member_accounts ON member_accounts.id = account_transactions.subsidiary_id
                  LEFT JOIN
                    members ON members.id = member_accounts.member_id
                  WHERE
                    account_transactions.transacted_at BETWEEN '#{@start_date}' AND '#{@end_date}' 
                    AND member_accounts.account_type = 'INSURANCE' 
                    AND member_accounts.account_subtype = 'Life Insurance Fund' 
                    AND members.branch_id = '#{@branch.id}'
                    AND members.insurance_status IN ('inforce', 'lapsed')
                  GROUP BY
                    transaction_id,
                    member_account_id,
                    recognition_date,
                    members.id
                  ORDER BY
                    account_transactions.id, account_transactions.transacted_at DESC
                EOS
    end
  end
end