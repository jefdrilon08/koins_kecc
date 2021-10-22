module AccruedPaymentCollections
  class ValidateWithdrawPayment
    
    def initialize(data_store_id:, member_id:, loan_amount:, member_account_id:)
      @errors = {messages: []}
      @accrued_billing = AccruedBilling.find(data_store_id)
      @member_id = member_id
      @wp_amount = loan_amount.to_f
      @member_account_id = member_account_id
      @savings_id = @accrued_billing.data['member_data'][@member_id]['loan_data'][@member_account_id]['mem_acc']
      @loan_id = @accrued_billing.data['member_data'][@member_id]['loan_data'][@member_account_id]['loan_id']
 
    end
      
    def execute!
      if @savings_id.present?
        mem_acc = MemberAccount.find(@savings_id)
        if mem_acc.balance.to_f < @wp_amount
          @errors[:messages] << {
            key:  "billing",
            message: "not enough funds"
                             } 
        end
      end

      if @loan_id.present?
        loan_acc = Loan.find(@loan_id).data['accrued_interest']
        balance = loan_acc['total_accrued_interest'] - loan_acc['total_accrued_interest_balance']
        if balance.to_f < @wp_amount
          @errors[:messages] << {
            key:  "billing",
            message: "amount is higher than accrued interest"
                             } 
        end

      end

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      
      @errors
    end

  end
end

