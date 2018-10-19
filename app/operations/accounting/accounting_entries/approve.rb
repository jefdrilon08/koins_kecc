module Accounting
  module AccountingEntries
    class Approve
      def initialize(config:)
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @user             = @config[:user]
      end

      def execute!
      end
    end
  end
end
