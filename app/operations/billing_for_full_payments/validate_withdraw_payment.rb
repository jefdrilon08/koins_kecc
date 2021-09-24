module BillingForFullPayments
  class ValidateWithdrawPayment
    def initialize(data_store_id:, member_id:, loan_amount:)
      @errors = {messages: []}
      @member_id = member_id
      @wp_amount = loan_amount
      @member_savings_account = MemberAccount.where(member_id: @member_id, account_subtype: "K-IMPOK")
    end
    def execute!
      if @member_savings_account.present?
        if @member_savings_account.last.balance.to_f < @wp_amount.to_f
          @errors[:messages] << {
                                key:  "billing",
                                message: "not enough funds"
                             } 
        end
      end

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      
      @errors
     

    end
  end
end
