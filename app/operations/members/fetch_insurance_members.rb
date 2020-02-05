module Members
  class FetchInsuranceMembers
    def initialize(config:)
      @config           = config
      @a_members          = @config[:members]
      @as_of            = @config[:as_of]
      @insurance_status = @config[:insurance_status] 

      @members = []
    end

    def execute!
      @member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Life Insurance Fund", @a_members.pluck(:id))
      @account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND transacted_at <= ?", @member_accounts.pluck(:id), @as_of)
      @current_date = @as_of
      @default_periodic_payment  = 15

      @a_members.each_with_index do |member, i|
        recognition_date          = member.recognition_date

        if recognition_date.present?
          current_member_account = @member_accounts.select{ |o| o.member_id == member.id }.first
          if !current_member_account.nil?
            transactions = @account_transactions.select{ |o| o.subsidiary_id == current_member_account.id }

            if transactions.size > 0
              latest            = transactions.last
              last_payment_date = transactions.last[:transacted_at].to_date
              
              # Code
              current_balance          = current_member_account.balance.to_i
              num_days                 = (@current_date - recognition_date).to_i
              num_weeks                = (num_days / 7).to_i + 1
              insured_amount           = num_weeks * @default_periodic_payment
              amt_past_due             = (current_balance - insured_amount).to_i * -1
              days_lapsed              = (@current_date - last_payment_date).to_i
              
              if current_balance == 0.00 && latest.data.with_indifferent_access[:is_withdraw_payment] == true
                insurance_status = "resigned"
              elsif current_balance == 0.00
                insurance_status = "dormant"
              elsif days_lapsed <= 45 && current_balance >= insured_amount
                insurance_status = "inforce"
              elsif days_lapsed > 45 && current_balance >= insured_amount
                insurance_status = "inforce"
              elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due < 97
                insurance_status = "inforce"
              elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due >= 97
                insurance_status = "lapsed"  
              elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due >= 97
                insurance_status = "lapsed"
              elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due < 97
                insurance_status = "inforce"  
              end
            elsif transactions.size == 0
              insurance_status = "dormant"
            end
          end
        else
          insurance_status = "pending"
        end

        if insurance_status == @insurance_status
          @members << member
        end
      end

      @members
    end
  end
end
