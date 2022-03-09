module CommissionCollections
  class BuildAccountingEntry
    def initialize(config:)
      @config = config

      @data                       = @config[:data]
      @user                       = @config[:user]
      @date_prepared              = @config[:date_prepared].try(:to_date) || Date.today
      @start_date                 = @config[:start_date]
      @end_date                   = @config[:end_date]
      @default_branch             = @config[:default_branch]
      @category                   = @config[:category]
      @accounting_fund            = AccountingFund.where(name: "Mutual Benefit Fund").first

      @accounting_entry_data  = {
        book: @config[:book] || "JVB",
        date_prepared: @date_prepared.strftime("%B %d, %Y"),
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
      if @category == "referrer"
        "Referrer commision!"
      elsif @category == "insurance coordinator"
        "Insurance coordinator commision!"
      end
    end

    def build_debit_journal_entries!
      journal_entries = []

      accounting_code = AccountingCode.find("c2f80584-a24a-437b-b161-80f4b0a12d9c")
      amount          = 0.00

      @data[:records].each do |r|
        amount += r[:commission].to_f
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

      accounting_code = AccountingCode.find("e6b9136c-a0a5-456f-bc59-0370f9b9594a")
      amount          = 0.00

      @data[:records].each do |r|
        amount += r[:commission].to_f
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
