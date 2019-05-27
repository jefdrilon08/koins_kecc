module MembershipPaymentCollections
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
        status: "display",
        data: {
          or_number: "",
          ar_number: ""
        }
      }

      @membership_parameters  = Settings.memberships
      @default_equities_key   = Settings.default_equities_key

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

      # Equity settings
      @equity_settings = nil

      Settings.equity_accounting_codes.each do |o|
        if o.equity_type == @default_equities_key
          @equity_settings  = o
        end
      end

      if @equity_settings.blank?
        raise "No equity settings found"
      end

      # Insurance accounting codes
      @insurance_accounting_codes = Settings.insurance_accounting_codes

      if @insurance_accounting_codes.blank?
        raise "No insurance_accounting_codes found in settings"
      end

      # Savings accounting codes
      @savings_accounting_codes = Settings.savings_accounting_codes

      if @savings_accounting_codes.blank?
        raise "No savings_accounting_codes found in settings"
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

      # ID
      id_accounting_code = AccountingCode.find(Settings.default_id_fee_accounting_code_id)

      id_amount  = 0.00
      @data[:totals].each do |o|
        if o[:record_type] == "ID"
          id_amount  = o[:amount].to_f.round(2)
        end
      end

      journal_entries << {
        accounting_code_id: id_accounting_code.id,
        code: id_accounting_code.code,
        name: id_accounting_code.name,
        amount: id_amount
      }

      # MEMBERSHIP PAYMENTS
      @membership_parameters.each do |p|
        @data[:totals].each do |o|
          if o[:record_type] == "MEMBERSHIP_PAYMENT" and o[:key] == p.name and o[:amount] > 0
            accounting_code = AccountingCode.find(p[:accounting_code_id])
            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: accounting_code.code,
              name: accounting_code.name,
              amount: o[:amount]
            }
          end
        end
      end

      # SHARE CAPITAL
      equity_accounting_code  = AccountingCode.find(@equity_settings.deposit_accounting_code_id)

      @data[:totals].each do |o|
        if o[:record_type] == "EQUITY" and o[:key] == @default_equities_key and o[:amount] > 0
          journal_entries << {
            accounting_code_id: equity_accounting_code.id,
            code: equity_accounting_code.code,
            name: equity_accounting_code.name,
            amount: o[:amount]
          }
        end
      end

      # INSURANCE
      @insurance_accounting_codes.each do |s|
        @data[:totals].each do |o|
          if o[:record_type] == "INSURANCE" and o[:key] == s.insurance_type and o[:amount] > 0
            accounting_code = AccountingCode.find(s.deposit_accounting_code_id)

            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: accounting_code.code,
              name: accounting_code.name,
              amount: o[:amount]
            }
          end
        end
      end

      # SAVINGS
      @savings_accounting_codes.each do |s|
        @data[:totals].each do |o|
          if o[:record_type] == "SAVINGS" and o[:key] == s.savings_type and o[:amount] > 0
            accounting_code = AccountingCode.find(s.deposit_accounting_code_id)

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
      "TO RECORD PAYMENT FOR SC, MF and ID #{@branch.name}"
    end
  end
end
