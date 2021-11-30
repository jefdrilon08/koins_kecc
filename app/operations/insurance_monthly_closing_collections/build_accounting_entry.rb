module InsuranceMonthlyClosingCollections
  class BuildAccountingEntry
    def initialize(config:)
      @config = config

      @data                       = @config[:data]
      @branch                     = @config[:branch]
      @settings                   = @config[:settings]
      @user                       = @config[:user]
      @collection_date            = @config[:collection_date].try(:to_date) || Date.today
      @closing_date               = @config[:closing_date]
      @default_branch             = @config[:default_branch]
      @accounting_fund            = AccountingFund.where(name: "Mutual Benefit Fund").first

      @accounting_entry_data  = {
        book: @config[:book] || "JVB",
        date_prepared: @collection_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @default_branch.to_s.upcase,
        prepared_by: @user.full_name,
        particular: default_particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @default_branch.id,
        branch_name: @default_branch.name,
        status: "display",
        accounting_fund_id: @accounting_fund.id,
        data: {
          or_number: "",
          ar_number: ""
        }
      }
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

    def default_particular
      if @settings.account_subtype == "Retirement Fund"
        "Increase in RF for #{@branch.to_s}. Closing date: #{@closing_date.to_date}"
      elsif @settings.account_subtype == "Equity Value"
        "Increase in EV for #{@branch.to_s}. Closing date: #{@closing_date.to_date}"
      end
    end

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = AccountingCode.find(@settings.debit_accounting_code_id)
      amount          = 0.00

      @data[:records].each do |r|
        amount += r[:interest].to_f
      end

      amount = amount.round(2)

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: amount
      }

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      accounting_code = AccountingCode.find(@settings.credit_accounting_code_id)
      amount          = 0.00

      @data[:records].each do |r|
        amount += r[:interest].to_f
      end

      amount = amount.round(2)

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: amount
      }

      journal_entries
    end
  end
end
