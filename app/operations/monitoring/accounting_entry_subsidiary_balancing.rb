module Monitoring
  class AccountingEntrySubsidiaryBalancing
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date) || Date.today
      @branch = @config[:branch]

      @settings_loan_products = Settings.loan_products

      if @settings_loan_products.blank?
        raise "settings_loan_products not found"
      end

      @settings_savings_accounting_codes    = Settings.savings_accounting_codes

      if @settings_savings_accounting_codes.blank?
        raise "settings_savings_accounting_codes not found"
      end

      @settings_insurance_accounting_codes  = Settings.insurance_accounting_codes

      if @settings_insurance_accounting_codes.blank?
        raise "settings_insurance_accounting_codes not found"
      end

      @settings_equity_accounting_codes     = Settings.equity_accounting_codes

      @journal_entries  = JournalEntry.joins(:accounting_entry).where(
                            "accounting_entries.status = ? AND accounting_entries.date_posted <= ? AND accounting_entries.branch_id = ?",
                            "approved",
                            @as_of,
                            @branch.id
                          ).order("accounting_entries.date_posted ASC")



      @data = {
        loans_receivables: [],
        personal_funds: []
      }
    end

    def execute!
      fetch_loans_receivables!
      fetch_personal_funds!

      @data
    end

    private

    def fetch_personal_funds!
      # SAVINGS
      @settings_savings_accounting_codes.each do |o|
        account_type    = "SAVINGS"
        account_subtype = o.savings_type

        d = {
          accounting_code: {
            id: "",
            name: "",
            code: ""
          },
          account: {
            account_type: account_type,
            account_subtype: account_subtype
          },
          accounting_entry_balance: 0.00,
          subsidiary_balance: 0.00,
          diff: 0.00
        }

        accounting_code = AccountingCode.find(o.deposit_accounting_code_id)
        d[:accounting_code][:id]    = accounting_code.id
        d[:accounting_code][:name]  = accounting_code.name
        d[:accounting_code][:code]   = accounting_code.code

        debit_amount  = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'DR').sum(:amount)
        credit_amount = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'CR').sum(:amount)

        d[:accounting_entry_balance]  = (credit_amount - debit_amount).round(2)

        member_accounts = MemberAccount.where(
                            account_type: account_type,
                            account_subtype: account_subtype,
                            branch_id: @branch.id
                          )

        account_transactions  = AccountTransaction.savings.where(subsidiary_id: member_accounts.pluck(:id)).where("DATE(transacted_at) <= ?", @as_of).order("transacted_at ASC")

        deposits    = account_transactions.where(transaction_type: "deposit").sum(:amount)
        withdrawals = account_transactions.where(transaction_type: "withdraw").sum(:amount)

        d[:subsidiary_balance]  = deposits - withdrawals

        d[:diff]  = (d[:accounting_entry_balance] - d[:subsidiary_balance]).round(2)

        @data[:personal_funds] << d 
      end

      # EQUITY
      @settings_equity_accounting_codes.each do |o|
        account_type    = "EQUITY"
        account_subtype = o.equity_type

        d = {
          accounting_code: {
            id: "",
            name: "",
            code: ""
          },
          account: {
            account_type: account_type,
            account_subtype: account_subtype
          },
          accounting_entry_balance: 0.00,
          subsidiary_balance: 0.00,
          diff: 0.00
        }

        accounting_code = AccountingCode.find(o.deposit_accounting_code_id)
        d[:accounting_code][:id]    = accounting_code.id
        d[:accounting_code][:name]  = accounting_code.name
        d[:accounting_code][:code]   = accounting_code.code

        debit_amount  = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'DR').sum(:amount)
        credit_amount = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'CR').sum(:amount)

        d[:accounting_entry_balance]  = (credit_amount - debit_amount).round(2)

        member_accounts = MemberAccount.where(
                            account_type: account_type,
                            account_subtype: account_subtype,
                            branch_id: @branch.id
                          )

        account_transactions  = AccountTransaction.savings.where(subsidiary_id: member_accounts.pluck(:id)).where("DATE(transacted_at) <= ?", @as_of).order("transacted_at ASC")

        deposits    = account_transactions.where(transaction_type: "deposit").sum(:amount)
        withdrawals = account_transactions.where(transaction_type: "withdraw").sum(:amount)

        d[:subsidiary_balance]  = deposits - withdrawals

        d[:diff]  = (d[:accounting_entry_balance] - d[:subsidiary_balance]).round(2)

        @data[:personal_funds] << d 
      end
    end

    def fetch_loans_receivables!
      @settings_loan_products.each do |o|
        d = {
          accounting_code: {
            id: "",
            name: "",
            code: ""
          },
          loan_product: {
            id: "",
            name: ""
          },
          accounting_entry_balance: 0.00,
          subsidiary_balance: 0.00,
          diff: 0.00
        }

        loan_product    = LoanProduct.find(o.loan_product_id)

        d[:loan_product]  = {
          id: loan_product.id,
          name: loan_product.name
        }

        accounting_code = AccountingCode.find(o.receivable_accounting_code_id)

        d[:accounting_code] = {
          id: accounting_code.id,
          name: accounting_code.name,
          code: accounting_code.code
        }

        debit_amount  = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'DR').sum(:amount)
        credit_amount = @journal_entries.where(accounting_code_id: accounting_code.id, post_type: 'CR').sum(:amount)

        d[:accounting_entry_balance]  = (debit_amount - credit_amount).round(2)

        paid_loans  = Loan.paid.where(
                        "date_approved >= ? AND date_completed <= ? AND branch_id = ? AND loan_product_id = ?",
                        @as_of,
                        @as_of,
                        @branch.id,
                        loan_product.id
                      )

        active_loans  = Loan.active.where(
                          "branch_id = ? AND date_approved <= ? AND loan_product_id = ?",
                          @branch.id,
                          @as_of,
                          loan_product.id
                        )

        loans = Loan.where(id: [paid_loans.pluck(:id) + active_loans.pluck(:id)])

        payments  = AccountTransaction.approved_loan_payments.where(
                      "transacted_at <= ? AND subsidiary_id IN (?)",
                      @as_of,
                      loans.pluck(:id)
                    )

        total_principal = loans.sum(:principal).round(2)
        total_interest  = loans.sum(:interest).round(2)
        total_amount    = (total_principal + total_interest).round(2)

        total_principal_paid  = payments.sum("CAST(data->>'total_principal_paid' AS decimal)").round(2)
        total_interest_paid   = payments.sum("CAST(data->>'total_interest_paid' AS decimal)").round(2)
        total_paid            = (total_principal_paid + total_interest_paid).round(2)

        total_principal_portfolio = (total_principal - total_principal_paid).round(2)
        total_interest_portfolio  = (total_interest - total_interest_paid).round(2)
        total_portfolio           = (total_principal_portfolio + total_interest_portfolio).round(2)

        d[:subsidiary_balance]  = total_principal_portfolio
        
        d[:diff]  = (d[:accounting_entry_balance] - d[:subsidiary_balance]).round(2)

        @data[:loans_receivables] << d 
      end
    end
  end
end
