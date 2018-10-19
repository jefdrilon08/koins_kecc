module Accounting
  module AccountingEntries
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @user             = @config[:user]
      end

      def execute!
        not_yet_implemented!
        @errors
      end
    end
  end
end
