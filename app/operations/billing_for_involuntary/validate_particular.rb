module BillingForInvoluntary
    class ValidateParticular < AppValidator
        def initialize(config:)
            super()
            @config = config
            @data_store =DataStore.find(@config[:data_store_id])
            @particular  = @config[:particular]
        end
        def execute!
            if @data_store.blank?
                @errors[:messages] << {
                    key: "dataStore",
                    message: "data cannot find"
                  }
            end

            if @particular.blank?
                @errors[:messages] << {
                    key: "particular",
                    message: "particular cannot be empty"
                  }
            end

            @errors[:messages].each do |o|
                @errors[:full_messages] << o[:message]
            end
      
            @errors
        end
    end
end