module Billings
  class BuildAccountingEntry
    def initialize(billing:, config:)
      @config = config

      @branch   = @config[:branch]
      @billing  = @config[:billing]
      @user     = @config[:user]
      @data     = @billing.data.with_indifferent_access

      @accounting_entry_data  = {
        book: @config[:book],
        date_prepared: @config[:date_prepared],
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @user.full_name,
        particular: default_particular,
        debit_journal_entries: [],
        credit_journal_entries: []
      }

      @billing_accounting_code_settings = nil

      Settings.branch_billing_accounting_codes.each do |o|
        if o.branch_id == @branch.id
          @billing_accounting_code_settings = o
        end
      end

      # Trap settings not found
      if @billing_accounting_code_settings.blank?
        raise "No billing_accounting_code_settings found for branch #{@branch.id}"
      end
    end

    def execute!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
    end

    private

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = AccountingCode.find(@billing_accounting_code_settings.cash_in_bank_accounting_code_id)
      journal_entries << {
        code: accounting_code.code,
        name: accounting_code.name,
        amount: number_to_currency(@data.total_collected, unit: "")
      }

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      journal_entries
    end

    def default_particular
      "Default particular for billing"
    end
  end
end
