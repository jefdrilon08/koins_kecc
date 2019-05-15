module Loans
  class ValidateApproveAdjustmentRecord < AppValidator
    def initialize(config:)
      super()

      @config = config

      @adjustment_record  = @config[:adjustment_record]
      @user               = @config[:user]
    end

    def execute!
      if @adjustment_record.blank?
        @errors[:messages] << {
          key: "adjustment_record",
          message: "Not found"
        }
      elsif !@adjustment_record.pending?
        @errors[:messages] << {
          key: "status",
          message: "Record is not pending"
        }
      end

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
