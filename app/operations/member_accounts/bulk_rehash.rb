module MemberAccounts
  class BulkRehash
    attr_accessor :account_subtype

    def initialize(config:, account_subtype: )
      @config = config
      @branch = @config[:branch]
      @account_subtype  = account_subtype
    end

    def execute!
      query!

      sets_array  = []

      member_account_sets = []

      @result.group_by{ |tx| tx["id"] }.each do |id, txs|
        running_balance   = 0.00
        beginning_balance = 0.00
        ending_balance    = 0.00

        temp_sets = txs.map.with_index{ |t, i|
                      updated_at      = Time.now + i.second
                      transaction_id  = t.fetch("transaction_id")

                      if t.fetch("transaction_type") == "deposit"
                        ending_balance  = (beginning_balance + t.fetch("amount").to_f.round(2)).to_f.round(2)
                      elsif t.fetch("transaction_type") == "withdraw"
                        ending_balance  = (beginning_balance - t.fetch("amount").to_f.round(2)).to_f.round(2)
                      end

                      data  = JSON.parse(t.fetch("data"))
                      data["beginning_balance"] = beginning_balance
                      data["ending_balance"]    = ending_balance
                      
                      # WORKAROUND: Do not save particulars
                      data["accounting_entry_particular"] = ""

                      beginning_balance = ending_balance

                      "('#{transaction_id}', '#{data.to_json}', '#{updated_at.to_s(:db)}')"
                    }.join(",")

        temp_sets.split(",").each do |o|
          sets_array << o
        end

        member_account_sets << "('#{id}', #{ending_balance})"
      end

      sets                = sets_array.join(",")
      member_account_sets = member_account_sets.join(",")


      if sets.present?
        query = "
          UPDATE account_transactions AS a SET
            data = CAST(temp.data AS json),
            updated_at = temp.updated_at::timestamp
          FROM (values
            #{sets}
          ) AS temp(transaction_id, data, updated_at)
          WHERE temp.transaction_id = a.id::text
        "

        #binding.pry
        ActiveRecord::Base.connection.execute(query)

        # Update member accounts
        query = "
          UPDATE member_accounts AS m SET
            balance = temp.ending_balance
          FROM (values
            #{member_account_sets}
          ) AS temp(id, ending_balance)
          WHERE temp.id = m.id::text
        "

        ActiveRecord::Base.connection.execute(query)
      end
    end

    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT
                    member_accounts.id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    account_transactions.id AS transaction_id,
                    (account_transactions.data->>'beginning_balance')::float AS beginning_balance,
                    account_transactions.amount,
                    (account_transactions.data->>'ending_balance')::float AS ending_balance,
                    account_transactions.transaction_type,
                    account_transactions.data AS data
                  FROM
                    member_accounts
                  INNER JOIN
                    account_transactions ON account_transactions.subsidiary_id = member_accounts.id AND account_transactions.status = 'approved'
                  WHERE
                    member_accounts.branch_id = '#{@branch.id}' and
                    member_accounts.account_subtype = '#{@account_subtype}'
                  ORDER BY
                    member_accounts.id, member_accounts.account_type, member_accounts.account_subtype, account_transactions.transacted_at ASC, account_transactions.updated_at ASC
                EOS
    end
  end
end
