module InsuranceWithdrawalCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                           = config
      @insurance_withdrawal_collection  = @config[:insurance_withdrawal_collection]
      @user                             = @config[:user]

      @data = @insurance_withdrawal_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @insurance_withdrawal_collection.blank?
        @errors[:messages] << {
          key: "insurance_withdrawal_collection",
          message: "insurance_withdrawal_collection not found"
        }
      end

      if @data[:records].present? 
        @data[:records].each do |record|
          member = Member.find(record[:member][:id])

          @life_account = member.member_accounts.where(account_subtype: "Life Insurance Fund").first
          @life_balance = @life_account.balance
          @ev_amount = 0.0
          @life_amount = 0.0

          record[:records].each do |rec|
            if rec[:record_type] == "INSURANCE" and rec[:account_subtype] == "Equity Value"
              @ev_amount = @ev_amount + rec[:amount].to_f
            end

            if rec[:record_type] == "INSURANCE" and rec[:account_subtype] == "Life Insurance Fund"
              @life_amount = @life_amount + rec[:amount].to_f
            end
          end

          if @life_amount > 0.0 and @ev_amount <= 0.0
            @errors[:messages] << {
              key: "records",
              message: "Equity Value can't be zero for #{member.full_name}. \n NOTE: If for adjustment, enter half of LIFE amount. \n If for zero out of member accounts. Enter all EV amount"
            }
          end
        end
      end

      if @data.present? and @data[:records].size == 0
        @errors[:messages] << {
          key: "records",
          message: "no records found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
