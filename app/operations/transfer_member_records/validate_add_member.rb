module TransferMemberRecords
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config = config
      @center = @config[:center]
      @transfer_member_records = @config[:transfer_member_records]
      @member = @config[:member]
      @active_loans = @config[:active_loans]
      @member_accounts = @config[:member_accounts]
     
    end

    def execute!
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      end

   
      if @center.blank?
          @errors[:messages] << {
            key: "center",
            message: "center not found"
          }
      end
      if @member.present?
        data_rec = @transfer_member_records.data.with_indifferent_access[:records]
        data_rec.each do |dr|
          if dr[:member][:id] == @member.id
            @errors[:messages] << {
              key: "member present",
              message: "Duplicate member"
            }
          end
        end 
      end

      #not_yet_implemented!
      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end
      @errors
    end
  end
end
