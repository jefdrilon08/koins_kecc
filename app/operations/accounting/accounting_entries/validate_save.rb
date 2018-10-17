module Accounting
  module AccountingEntries
    class ValidateSave < AppValidator
      def initialize(config:)
        super()
        @config = config.with_indifferent_access

        @accounting_entry_data  = @config[:accounting_entry_data]
        @user                   = @config[:user]
      end

      def execute!
        if @accounting_entry_data[:journal_entries].size <= 1
          @errors[:messages] << {
            key: "journal_entries",
            message: "no journal entries found"
          }
        else
          # TODO: Check balancing of journal entries
        end

        # Check for book
        if @accounting_entry_data[:book].blank?
          @errors[:messages] << {
            key: "book",
            message: "Book required"
          }
        end

        # Check for particular
        if @accounting_entry_data[:particular].blank?
          @errors[:messages] << {
            key: "particular",
            message: "Particular required"
          }
        end

        @errors
      end
    end
  end
end
