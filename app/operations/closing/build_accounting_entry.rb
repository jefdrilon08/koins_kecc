module Closing
  class BuildAccountingEntry
    def initialize(config:)
      @config = config
      @data   = @config[:data]
      @book   = "MISC"

      @current_date = Date.today
      @particular   = @config[:particular]
      @prepared_by  = @config[:prepared_by]
      @branch       = @config[:branch]
      
      @accounting_fund  = @config[:accounting_fund]

      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @prepared_by,
        particular: @particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @branch.id,
        branch_name: @branch.name,
        status: "display",
        accounting_fund_id: @accounting_fund.try(:id),
        data: {
          or_number: "",
          ar_number: "",
          check_number: "",
          check_voucher_number: "",
          date_of_check: "",
          sub_reference_number: "",
          payee: "",
          is_closing_record: true
        }
      }
    end

    def execute!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: "#{j[:code]} - #{j[:name]}",
          amount: j[:amount]
        }
      end

      @accounting_entry_data
    end

    private

    def build_debit_journal_entries!
      journal_entries = []

      @data[:closing_entries][:debit].each do |e|
        journal_entries << {
          accounting_code_id: e[:accounting_code][:id],
          code: e[:accounting_code][:code],
          name: e[:accounting_code][:name],
          amount: e[:debit]
        }
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      @data[:closing_entries][:credit].each do |e|
        journal_entries << {
          accounting_code_id: e[:accounting_code][:id],
          code: e[:accounting_code][:code],
          name: e[:accounting_code][:name],
          amount: e[:credit]
        }
      end

      journal_entries
    end
  end
end
