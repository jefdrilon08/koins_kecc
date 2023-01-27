module TransferMemberRecords
  class ValidateCenter < AppValidator
    def initialize(config:)
      super()

      @config = config
      @from_center = Center.find(config[:from_center])
      @to_center = Center.find(config[:to_center])
      @from_center_member = Member.where(center_id: @from_center.id)

     
    end

    def execute!
      if @from_center_member.count == 0
        @errors[:messages] << {
          key: "center member count",
          message: "Center has no Member"
        }
      end

      #not_yet_implemented!
      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end
     
      @errors
    end
  end
end
