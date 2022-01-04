module BillingForWriteoff
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()

        @config       = config
        @data_store   = config[:data_store]
        @user         = config[:user]
      end

      def execute!
        if @data_store.blank?
          @errors[:messages] << {
            key: "billing_for_writeoff",
            message: "record Not Found"
          }
        end

        if @user.blank?
           @errors[:messages] << {
            key: "user",
            message: "user not found"
          }
        end

        
        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
   
  end
end
