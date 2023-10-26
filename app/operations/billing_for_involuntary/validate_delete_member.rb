module BillingForInvoluntary
    class ValidateDeleteMember < AppValidator
        def initialize(config:)
            super()
            @data_store = DataStore.find(config[:data_store_id])
            @data = @data_store.data.with_indifferent_access
            @member_id = config[:member_id]
        end
        def execute!
            if    @data_store.status != "pending"
                @errors[:messages] << {
                    key: "dataStore",
                    message: "collection status is #{@data_store.status}"
                }
            end
            @errors[:messages].each do |o|
                @errors[:full_messages] << o[:message]
            end
      
            @errors  
        end
    end
end