module BillingForFullPayments
  class ValidatePayment
    def initialize(config:)
      @config             = config
      @member_id          = @config[:member_id]
      @member_account_id  = @config[:member_account_id]
      @data_store_id      = @config[:data_store_id]
      @record_type        = @config[:record_type]
      @loan_amount        = @config[:loan_amount]
      
    end

    def execute!
      
        data_store = DataStore.find(@data_store_id)
        data_store_details = data_store["data"].select{ |b| b["member_id"] ==  @member_id }.first["balance"].select{ |bb| bb["member_account_id"] == @member_account_id }.first

        raise data_store_details["amount"].inspect

        #if data_store_details["amount"] > @loan_amount || data_store_details["amount"] < @loan_amount
         # @errors << {
        #    message: "no or number found"
        #  }
        #end

        @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

         @errors.inspect

        
    end

  end
end
