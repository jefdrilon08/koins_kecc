module Accounting
  module AccountingCodes
    class SaveMonthlySummary
      def initialize(accounting_code:, branch:, month:, year:)
        @accounting_code  = accounting_code
        @branch           = branch
        @month            = month
        @year             = year

        @record = MonthlyAccountingCodeSummary.new(
                    month:            @month,
                    year:             @year,
                    branch:           @branch,
                    accounting_code:  @accounting_code,
                    dr_amount:        0.00,
                    cr_amount:        0.00
                  )
      end

      def execute!
        entries = JournalEntry.joins(:accounting_entry).select(
                    "journal_entries.id AS id, accounting_entries.date_posted, accounting_entries.status, journal_entries.amount, journal_entries.post_type, journal_entries.accounting_code_id"
                  ).where(
                    "EXTRACT(YEAR from accounting_entries.date_posted) = ? AND EXTRACT(MONTH from accounting_entries.date_posted) = ? AND accounting_entries.status = ? AND journal_entries.accounting_code_id = ?",
                    @year,
                    @month,
                    "approved",
                    @accounting_code.id
                  )

        if entries.any?
          @record.dr_amount = entries.where("journal_entries.post_type = ?", "DR").sum(:amount).round(2)
          @record.cr_amount = entries.where("journal_entries.post_type = ?", "CR").sum(:amount).round(2)
        end

        @record.save!

        @record
      end
    end
  end
end
