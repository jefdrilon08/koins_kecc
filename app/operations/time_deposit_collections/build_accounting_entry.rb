module TimeDepositCollections
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

      @settings = Settings.time_deposit

      if @settings.blank?
        raise "Settings for time deposit not found"
      end

      @branch_accounting_codes  = Settings.branch_accounting_codes

      if @branch_accounting_codes.blank?
        raise "Settings for branch_accounting_codes not found"
      end

      @branch_accounting_code = @branch_accounting_codes.select{ |o|
                                  o.branch_id == @branch.id
                                }.first

      if @branch_accounting_code.blank?
        raise "Settings for branch_accounting_code not found"
      end

      @cash_in_bank_accounting_code = AccountingCode.find(@branch_accounting_code.cash_in_bank_accounting_code_id)
      @deposit_accounting_code      = AccountingCode.find(@settings.deposit_accounting_code_id)
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

      accounting_code = @cash_in_bank_accounting_code

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

      @data[:totals].each do |o|
        accounting_code = @deposit_accounting_code
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: o[:amount]
        }
      end

      journal_entries
    end

    def default_particular
      "TO RECORD TIME DEPOSIT OF #{@branch.name}"
    end
  end
end
