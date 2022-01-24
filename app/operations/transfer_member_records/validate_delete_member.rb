module TransferMemberRecords
    class ValidateDeleteMember < AppValidator
      def initialize(config:)
        super()
        @transfer_member_records = TransferMemberRecord.find(config[:transfer_member_records])
        @member_id = config[:member_id]
      
      end

      def execute!
        if @transfer_member_records[:status] != "pending"
          @errors[:messages] << {
            key: "transfer_member_records",
            message: "record is not pending"
          }
        end

        if @member_id.blank?
           @errors[:messages] << {
            key: "member",
            message: "member not found"
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
