module BillingForFullPayments
  class ValidateAddMember
    def initialize(config:)
      super()
      @errors = {messages: []}
      @config =  config
      @member_id =  @config[:member_id]
      @loan_product_id =  @config[:member_loan_id]

      @loan_count = Loan.where(member_id: @member_id, loan_product_id: @loan_product_id)
    end
    def execute!
      if @loan_count.blank?
        @errors[:messages] << {
                                key:  "billing",
                                message: "member loan not found"
                             } 
      
      end
      
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
      
    end

  end
end
