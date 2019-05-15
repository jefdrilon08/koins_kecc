module Loans
  class ApproveAdjustmentRecord < AppValidator
    def initialize(config:)
      @config = config

      @adjustment_record  = @config[:adjustment_record]
      @user               = @config[:user]
    end

    def execute!
      raise "not yet implemented!"
    end
  end
end
