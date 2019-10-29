module Accounting
  module AccountingEntries
    class Save
      def initialize(config:)
        @config = config

        @id                     = @config[:id]
        @accounting_entry_data  = @config[:accounting_entry_data]
        @user                   = @config[:user]

        @branch           = Branch.find(@accounting_entry_data[:branch_id])
        @accounting_entry = AccountingEntry.new

        if @id.present?
          @accounting_entry = AccountingEntry.find(@id)
        end

        @current_journal_entry_ids = []

        @accounting_entry_data[:journal_entries].each do |o|
          if o[:id].present?
            @current_journal_entry_ids << o[:id]
          end
        end
      end

      def execute!

        @accounting_entry.particular    = @accounting_entry_data[:particular]
        @accounting_entry.book          = @accounting_entry_data[:book]
        @accounting_entry.branch        = @branch
        @accounting_entry.data          = @accounting_entry_data[:data]
        @accounting_entry.date_prepared = @accounting_entry_data[:date_prepared]
        @accounting_entry.prepared_by   = @accounting_entry_data[:prepared_by]

        # Get accounting fund if present
        if @accounting_entry_data[:accounting_fund_id].present?
          @accounting_entry.accounting_fund = AccountingFund.find(@accounting_entry_data[:accounting_fund_id])
        end

        # Remove unwanted journal entries
        if !@accounting_entry.new_record?
          existing_journal_entry_ids  = @accounting_entry.journal_entries.pluck(:id)
          unwanted_journal_entry_ids  = (@current_journal_entry_ids - existing_journal_entry_ids) | (existing_journal_entry_ids - @current_journal_entry_ids)

          if unwanted_journal_entry_ids.size > 0
            unwanted_journal_entry_ids.each do |unwanted_id|
              JournalEntry.find(unwanted_id).destroy!
            end

            @accounting_entry = AccountingEntry.find(@accounting_entry.id)
          end
        end

        @accounting_entry_data[:journal_entries].each do |o|
          if o[:id].present?
            temp  = JournalEntry.find(o[:id])

            temp.update!(
              accounting_code: AccountingCode.find(o[:accounting_code_id]),
              post_type: o[:post_type],
              amount: o[:amount]
            )
          else
            @accounting_entry.journal_entries <<  JournalEntry.new(
                                                    accounting_code: AccountingCode.find(o[:accounting_code_id]),
                                                    post_type: o[:post_type],
                                                    amount: o[:amount]
                                                  )
          end
        end

        @accounting_entry.save!

        @accounting_entry
      end
    end
  end
end
