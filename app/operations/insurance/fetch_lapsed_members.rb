module Insurance
  class FetchLapsedMembers
    attr_accessor :data
    def initialize(config:)
      @config = config
      @current_date = @config[:current_date].to_date
      @branches     = Branch.all
    
      @data = {
        current_date: @current_date,
        lapsed: [],

      }
    end

    def execute!
      query!

      @lapsed = []

      @branches.each do |branch|
        @result.select{ |res| res["branch_id"] == branch.id }.to_a.map{ |o|

          member_id                 = o.fetch("member_id")
          first_name                = o.fetch("fname")
          middle_name               = o.fetch("mname")
          last_name                 = o.fetch("lname")
          default_periodic_payment  = 15
          recognition_date          = o.fetch("recognition_date").try(:to_date)
          transactions_count        = o.fetch("acc_trans_count")

          new_status        = "dormant"
          insurance_status  = o.fetch("insurance_status")
          insurance_date_resigned  = o.fetch("insurance_date_resigned")
          status      = o.fetch("status")
          member_type = o.fetch("member_type")
          last_payment_date = o.fetch("transacted_at").try(:to_date)

          if recognition_date.present? and last_payment_date.present?
            # Code
            if transactions_count > 0 
              current_balance         = o.fetch("balance").to_f.round(2)
              num_days                = (@current_date - recognition_date).to_i
              num_weeks               = (num_days / 7).to_i + 1
              insured_amount          = num_weeks * default_periodic_payment
              amt_past_due            = (current_balance - insured_amount).to_i * -1
              days_lapsed             = (@current_date - last_payment_date).to_i

              is_withdraw_payment = o.fetch("is_withdraw_payment")

              if o.fetch("balance").to_f.round(2) == 0.00 && insurance_status == "resigned"  
                new_status = "resigned"
              elsif current_balance == 0.00 && is_withdraw_payment == "true"
                new_status = "resigned"
              elsif current_balance == 0.00 && !insurance_date_resigned.nil?
                new_status = "resigned"
              elsif days_lapsed <= 76 && current_balance >= insured_amount
                new_status = "inforce"
              elsif days_lapsed > 76 && current_balance >= insured_amount
                new_status = "inforce"
              elsif days_lapsed <= 76 && current_balance < insured_amount && amt_past_due < 163
                new_status = "inforce"
              elsif days_lapsed <= 76 && current_balance < insured_amount && amt_past_due >= 163
                new_status = "lapsed"
              elsif days_lapsed > 76 && current_balance < insured_amount && amt_past_due >= 163
                new_status = "lapsed"
              elsif days_lapsed > 76 && current_balance < insured_amount && amt_past_due < 163
                new_status = "inforce"
              end
            else
              new_status = "dormant"
            end
          elsif recognition_date.present? and transactions_count == 0
            new_status = "dormant"
          else
            new_status = "pending"
          end

          if member_type == "GK"
            new_status = "resigned"
          elsif status == "active" && recognition_date.nil?
            new_status = "pending"
          elsif status == "pending"
            new_status = "pending"
          elsif status == "archived"
            new_status = "archived"
          elsif status == "cleared"
            new_status = "cleared"
          elsif status == "resigned" && !insurance_date_resigned.nil?
            new_status = "resigned"  
          end

          if new_status == "lapsed"
            @lapsed << {
              branch: {
                branch_id: branch.id,
                branch_name: branch.name,
              },
              staus: new_status,
              members: {
                member_id: member_id,
                first_name: first_name,
                middle_name: middle_name,
                last_name: last_name
              }
            }
          end  
        }
      
      end

      @data[:lapsed] << @lapsed

      @data
    end

    def query!
      @result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT DISTINCT ON(member_accounts.id)
                    member_accounts.id AS member_account_id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    account_transactions.id AS transaction_id,
                    account_transactions.transacted_at,
                    COALESCE(account_transactions.data->>'ending_balance', '0.00')::float AS balance,
                    account_transactions.data->>'is_withdraw_payment' AS is_withdraw_payment,
                    members.data->>'recognition_date' AS recognition_date,
                    members.id AS member_id,
                    members.last_name AS lname,
                    members.first_name AS fname,
                    members.middle_name AS mname,
                    members.member_type,
                    members.status,
                    members.insurance_status,
                    members.insurance_date_resigned,
                    members.branch_id,
                    COUNT(account_transactions) AS acc_trans_count
                  FROM
                    member_accounts
                  LEFT JOIN
                    account_transactions ON account_transactions.subsidiary_id = member_accounts.id
                  LEFT JOIN
                    members ON members.id = member_accounts.member_id
                  WHERE
                    insurance_status = 'inforce' AND member_accounts.account_type = 'INSURANCE' AND member_accounts.account_subtype = 'Life Insurance Fund'
                  GROUP BY
                    member_account_id,
                    transaction_id,
                    recognition_date,
                    members.id
                  ORDER BY
                    member_accounts.id, account_transactions.transacted_at DESC
                EOS
    end
  end
end
