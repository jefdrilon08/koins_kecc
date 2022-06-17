module AdditionalShare
  class ValidateAmount
  
    def initialize(config:)
      @errors           = {messages: []}
      @config             = config
      @member_account_id  = @config[:member_account_id]
      @withdraw_amount    = @config[:withdraw_amount]
    end

    def execute!
      mem_acc = MemberAccount.find(@member_account_id)
      if @withdraw_amount.to_f > mem_acc.balance.to_f 
        @errors[:messages] << {
          key:  "billing",
          message: "withdraw amount is larger than balance"
          }
      end
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors     
    end
  
  end
end
 
