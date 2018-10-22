module Accounting
  module AccountingEntries
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()
        @config = config.with_indifferent_access

        @accounting_entry = @config[:accounting_entry]
        @user             = @config[:user]

        @journal_entries  = @accounting_entry.journal_entries
      end

      def execute!
        validate_balanced!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end

      private

      def validate_balanced!
        debit_amount  = @journal_entries.debit.sum(:amount)
        credit_amount = @journal_entries.credit.sum(:amount)

        if debit_amount != credit_amount
          @errors[:messages] << {
            key: "journal_entries",
            message: "unbalanced entries. debit: #{debit_amount} credit: #{credit_amount}"
          }
        end
      end
    end
  end
end
