module BillingForFullPayments
  class ValidateAddMember
    def initialize(config:)
      super()
      @errors = {messages: []}
      @config =  config
      @member_id =  @config[:member_id]
      @loan_product_id =  @config[:member_loan_id]

      @loan_count = Loan.where(member_id: @member_id, loan_product_id: @loan_product_id, status: "active")
      @data_store = DataStore.find(@config[:data_store_id]).data
    end
    def execute!
      

      


      if @loan_count.blank?
        @errors[:messages] << {
                                key:  "billing",
                                message: "member loan not found"
                             } 

      else
        for_enabled_check = @data_store.select{ |o| o["member_id"]== @member_id  }.last["balance"].select{ |b| b["loan_product_id"] == @loan_product_id  }.last["enabled"]
        if for_enabled_check == true
        @errors[:messages] << {
                                key:  "billing",
                                message: "member exist to billing "
                             } 
      
      end
      end

      
      
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
      
    end

  end
end
