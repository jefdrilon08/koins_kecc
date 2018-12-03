module Print
  class BuildAccountingEntry
    include ActionView::Helpers::NumberHelper

    def initialize(accounting_entry:)
      @accounting_entry = accounting_entry
      @data             = {}
    end

    def execute!
      @data[:id]                = @accounting_entry.id
      @data[:date_prepared]     = @accounting_entry.date_prepared.strftime("%B %d, %Y")
      @data[:book]              = @accounting_entry.book
      @data[:reference_number]  = @accounting_entry.reference_number
      @data[:data]              = @accounting_entry.data
      @data[:prepared_by]       = @accounting_entry.prepared_by
      @data[:approved_by]       = @accounting_entry.approved_by
      @data[:company_name]      = Settings.company_name
      @data[:company_address]   = Settings.company_address
      @data[:branch]            = @accounting_entry.branch.to_s.upcase
      @data[:particular]        = @accounting_entry.particular

      if @accounting_entry.date_posted.present?
        @data[:date_posted] = @accounting_entry.date_posted.strftime("%B %d, %Y")
      end

      @data[:debit_journal_entries] = []

      @accounting_entry.journal_entries.debit.each do |o|
        @data[:debit_journal_entries] << {
          code: o.accounting_code.code, 
          name: o.accounting_code.name,
          amount: number_to_currency(o.amount, unit: "")
        }
      end

      @data[:credit_journal_entries] = []

      @accounting_entry.journal_entries.credit.each do |o|
        @data[:credit_journal_entries] << {
          code: o.accounting_code.code, 
          name: o.accounting_code.name,
          amount: number_to_currency(o.amount, unit: "")
        }
      end

      @data[:total_debit]   = number_to_currency(@accounting_entry.journal_entries.debit.sum(:amount), unit: "")
      @data[:total_credit]  = number_to_currency(@accounting_entry.journal_entries.credit.sum(:amount), unit: "")

      @data
    end
  end
end
