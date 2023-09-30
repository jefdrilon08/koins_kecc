module BillingForInvoluntary
    class ValidateCreate < AppValidator
      def initialize(config:)
        super()

        @config = config
        @branch = @config[:branch]
      end

      def execute!
        if DataStore.where("status = 'pending' and meta ->> 'branch_id' = ? and meta ->> 'data_store_type' = 'BILLING_FOR_WRITEOFF_COLLECTION'" , @branch.id).count > 0
          @errors[:messages] << {
            key: "branch",
            message: "Please resolve pending involuntary collection for #{@branch.to_s} before creating a new involuntary collection."
          }
         
        end

          @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
      end

        @errors
      end
    end
end
