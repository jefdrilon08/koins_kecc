module Adjustments
  module SubsidiaryAdjustments
    class Approve
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.with_indifferent_access

        @accounting_entry = @data[:accounting_entry]
      end

      def execute!
      end
    end
  end
end
