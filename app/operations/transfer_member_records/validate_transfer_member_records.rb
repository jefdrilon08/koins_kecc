module TransferMemberRecords
  class ValidateTransferMemberRecords < AppValidator
    def initialize(config:)
      super()

      @config = config
      @branch_id = config[:branch_id]
      @branch_id_to_transfer= config[:branch_id_to_transfer]
    end

    def execute!
      if @branch_id.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if @branch_id_to_transfer.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if  @branch_id.to_s.present? and @branch_id_to_transfer.to_s.present? and @branch_id == @branch_id_to_transfer
        @errors[:messages] << {
          key: "branches",
          message: "branch should not be the same"
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
