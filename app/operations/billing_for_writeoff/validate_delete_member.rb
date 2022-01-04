module BillingForWriteoff
    class ValidateDeleteMember < AppValidator
      def initialize(config:)
        super()

        @config = config
        @data_store = @config[:data_store]
        @member_id  = @config[:member_id]
        @loan_id    = @config[:loan_id]
        
      end

      def execute!
        if @data_store.blank?
          @errors[:messages] << {
            key: "data_store",
            message: "record not found"
          }
        end

        if @member_id.blank?
          @errors[:messages] << {
            key: "member_id",
            message: "member not found"
          }
        end
        
        if @loan_id.blank?
          @errors[:messages] << {
            key: "loan_id",
            message: "loan not found"
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
