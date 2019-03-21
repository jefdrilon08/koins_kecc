module DepositCollections
  class BuildAccountingEntry
    def initialize(config:)
      @config = config

      @branch = @config[:branch]
      @data   = @config[:data].with_indifferent_access
      @user   = @config[:user]
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today

      @accounting_entry_data  = {
        book: @config[:book] || "CRB",
        date_prepared: @collection_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @user.full_name,
        particular: default_particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @branch.id,
        branch_name: @branch.name,
        accounting_fund_id: "",
        status: "display",
        data: {
          or_number: "",
          ar_number: ""
        }       
      }

      @default_deposit_accounts   = Settings.default_deposit_accounts
      @savings_accounting_codes   = Settings.savings_accounting_codes
      @insurance_accounting_codes = Settings.insurance_accounting_codes

      @branch_accounting_code_settings = nil

      Settings.branch_accounting_codes.each do |o|
        if o.branch_id == @branch.id
          @branch_accounting_code_settings = o
        end
      end

      # Trap settings not found
      if @branch_accounting_code_settings.blank?
        raise "No branch_accounting_code_settings found for branch #{@branch.id}"
      end
    end 

    def execute!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!

      # Build journal entries
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      @accounting_entry_data
    end

    private

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = AccountingCode.find(@branch_accounting_code_settings.cash_in_bank_accounting_code_id)
      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: @data[:total_collected]
      }

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      # SAVINGS DEPOSITS
      @savings_accounting_codes.each do |p|
        @data[:totals].each do |o|
          if o[:record_type] == "SAVINGS" and o[:key] == p.savings_type and o[:amount] > 0
            accounting_code = AccountingCode.find(p.deposit_accounting_code_id)
            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: accounting_code.code,
              name: accounting_code.name,
              amount: o[:amount]
            }
          end
        end
      end

      # INSURANCE DEPOSITS
      @insurance_accounting_codes.each do |p|
        @data[:totals].each do |o|
          if o[:record_type] == "INSURANCE" and o[:key] == p.insurance_type and o[:amount] > 0
            accounting_code = AccountingCode.find(p.deposit_accounting_code_id)
            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: accounting_code.code,
              name: accounting_code.name,
              amount: o[:amount]
            }
          end
        end
      end

      journal_entries
    end

    def default_particular
      "TO RECORD DEPOSIT OF #{@branch.name}"
    end
  end
end
