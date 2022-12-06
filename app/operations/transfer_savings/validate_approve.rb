module TransferSavings
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config = config
      @users = User.find(@config[:user])
      @transfer_savings_records = TransferSavingsRecord.find(@config[:transfer_savings_record])
    end

    def execute!
      if @transfer_savings_records.status == "approved"
        @errors[:messages] << {
          key: "branch",
          message: "Record is already approved"
        }
      end

      if @users.nil?
        @errors[:messages] << {
          key: "branch record",
          message: "User not found"
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
