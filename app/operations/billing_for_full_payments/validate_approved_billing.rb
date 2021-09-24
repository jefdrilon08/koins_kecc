module BillingForFullPayments
  class ValidateApprovedBilling
    
    def initialize(config:)
      @errors = {messages: []}
      @config = config
      
      @data_store = DataStore.find(@config[:data_store_id])
      
      
    end

    def execute!
      
      if @data_store["meta"]["is_checked"] == false
      
        @errors[:messages] << {
          key: "billing",
          message: "this record has not been checked yet"
        }
      end
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      
      @errors

    end
  end
end
