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
      @payee                      = build_payee
      @accounting_fund            = AccountingFund.where(name: "General Fund").first

      @accounting_entry_data  = {
        book: @config[:book] || "CDB",
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
          ar_number: "",
          check_number: "",
          check_voucher_number: "",
          payee: @payee
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

    def build_payee
      payee = ""

      if @category == "insurance coordinator"
        payee = "Various Insurance Coordinators"
      else
        payee = "Various Referrers"
      end

      payee
    end

    def default_particular
      "To record membership enrollment expense for the period of #{@start_date.to_date.try(:strftime, "%B %d, %Y")} to #{@end_date.to_date.try(:strftime, "%B %d, %Y")}"
    end

    def build_debit_journal_entries!
      journal_entries = []

      # Membership Enrollment and Marketing Expense
      accounting_code = AccountingCode.find("29b15cac-0f8e-4870-8d60-7f774bfa8c38")
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

      if !@data.nil?
        if @data[:transaction_fee].present?
          transaction_fee = @data[:transaction_fee]

          if transaction_fee > 0.00
            # Bank and other charges
            dr_accounting_code  = AccountingCode.find("7669d18f-015f-4886-ab68-888a92f6c2d2")

            amount = transaction_fee

            journal_entries << {
              accounting_code_id: dr_accounting_code.id,
              code: dr_accounting_code.code,
              name: dr_accounting_code.name,
              amount: amount
            }
          end
        end
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      # Cash in Bank - Union Bank Gen. Fund
      accounting_code = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

      if !@data.nil?
        if @data[:template].present?
          Settings.templates.each do |template|
            if template.name == @data[:template]
              template.accounting_codes.each do |a|
                accounting_code = AccountingCode.find(a.cr_accounting_code_id)
              end
            end
          end
        end
      end

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

      if !@data.nil?
        if @data[:transaction_fee].present?
          transaction_fee = @data[:transaction_fee]
          
          if transaction_fee > 0.00
            # Cash in Bank - Union Bank Gen. Fund
            cr_accounting_code  = AccountingCode.find("9e26384f-7a27-4e89-b5d0-1017cfdccf0b")

            amount = transaction_fee

            journal_entries << {
              accounting_code_id: cr_accounting_code.id,
              code: cr_accounting_code.code,
              name: cr_accounting_code.name,
              amount: amount
            }
          end
        end
      end

      journal_entries
    end
  end
end
