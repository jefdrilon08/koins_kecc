module BillingForInvoluntary
    class ValidateApprove < AppValidator
    def initialize(config:)
        super()
        @data_store = DataStore.find(config[:data_store_id])
        @current_user = User.find(config[:current_user])
    end

    def execute!
        if @data_store.blank?
            @errors[:messages] << {
                key: "dataStore",
                message: "data cannot find"
              }
        end

        if @data_store.status != "pending"
            @errors[:messages] << {
                key: "dataStore",
                message: "collection status is #{@data_store.status}"
            }
        end

        if @current_user.blank?
            @errors[:messages] << {
                key: "User",
                message: "user cannot find"
            }
        end

        @errors[:messages].each do |o|
            @errors[:full_messages] << o[:message]
        end
  
        @errors
    end

    end
end