module TransferSavings
  class ValidateTransferSavings < AppValidator
    def initialize(config:)
      super()

      @config = config
      @branch_id = @config[:branch_id]
      @users = @config[:users]
      @transfer_savings_records = TransferSavingsRecord.where(branch_id: @branch_id)
    end

    def execute!
      if @branch_id.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if @branch_id.present? and @transfer_savings_records.present? 
        @errors[:messages] << {
          key: "branch record",
          message: "branch has records"
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
