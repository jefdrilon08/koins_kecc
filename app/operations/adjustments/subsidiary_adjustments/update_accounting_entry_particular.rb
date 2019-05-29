module Adjustments
  module SubsidiaryAdjustments
    class UpdateAccountingEntryParticular
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]
        @particular         = @config[:particular]

        @data = @adjustment_record.data.with_indifferent_access

        @accounting_entry = @data[:accounting_entry]
      end

      def execute!
        @accounting_entry[:particular]  = @particular

        @data[:accounting_entry]  = @accounting_entry

        @adjustment_record.update!(
          data: @data
        )
      end
    end
  end
end
