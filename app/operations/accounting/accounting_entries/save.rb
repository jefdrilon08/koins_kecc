module Accounting
  module AccountingEntries
    class Save < AppValidator
      def initialize(config:)
        @config = config

        @accounting_entry_data  = @config[:accounting_entry_data]
        @user                   = @config[:user]

        @branch = Branch.find(@accounting_entry_data[:branch_id])

        @accounting_entry = AccountingEntry.new(
                              particular: @accounting_entry_data[:particular],
                              book: @accounting_entry_data[:book],
                              branch: @branch,
                              data: @accounting_entry_data[:data],
                              date_prepared: @accounting_entry_data[:date_prepared]
                            )
      end

      def execute!
        @accounting_entry_data[:journal_entries].each do |o|
          @accounting_entry.journal_entries <<  JournalEntry.new(
                                                  accounting_code: AccountingCode.find(o[:accounting_code_id]),
                                                  post_type: o[:post_type],
                                                  amount: o[:amount]
                                                )
        end

        @accounting_entry.save!

        @accounting_entry
      end
    end
  end
end
