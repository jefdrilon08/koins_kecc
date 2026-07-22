module Billings
  class BuildAccountingEntry
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config = config

      @branch           = @config[:branch]
      @user             = @config[:user]
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @data             = @config[:data].with_indifferent_access
        
    


      @center           = @config[:center]

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

      @branch_accounting_code_settings = nil

#      Settings.branch_accounting_codes.each do |o|
#        if o.branch_id == @branch.id
#          @branch_accounting_code_settings = o
#        end
#      end

      @branch_accounting_code_settings  = Settings.branch_accounting_codes.select{ |o|
                                            o.branch_id == @branch.id
                                          }.first

      @savings_accounting_codes   = Settings.savings_accounting_codes
      @equity_accounting_codes   = Settings.equity_accounting_codes
      @insurance_accounting_codes = Settings.insurance_accounting_codes

      # Trap settings not found
      if @branch_accounting_code_settings.blank?
        raise "No branch_accounting_code_settings found for branch #{@branch.id}"
      end

      # Get loan_products in this billing
      loan_product_ids  = []
      
      @data[:records].first[:records].select{ |o|
        o[:record_type] == "LOAN_PAYMENT"
      }.each do |oo|
        loan_product_ids << oo[:loan_product][:id]
      end

#      @data[:records].each do |o|
#        o[:records].each do |oo|
#          if oo[:record_type] == "LOAN_PAYMENT"
#            loan_product_ids << oo[:loan_product][:id]
#          end
#        end
#      end

      @loan_products  = LoanProduct.where(id: loan_product_ids.uniq)

      @loan_product_accounting_codes  = Settings.loan_product_accounting_codes

      # Total withdraw payment and total default savings
      @total_wp        = 0.00
      @total_savings   = 0.00

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

      # Cash in Bank
      # if withdraw payment > 0
      #accounting_code = ReadOnlyAccountingCode.find(@branch_accounting_code_settings.cash_in_bank_accounting_code_id)
      accounting_code = ReadOnlyAccountingCode.find(@branch_accounting_code_settings.billing_cash_in_bank_record_id)
      amount          = @data[:total_collected]

      if @total_wp > 0
        amount  -= @total_wp
      end

      journal_entries << {
        accounting_code_id: accounting_code.id,
        code: accounting_code.code,
        name: accounting_code.name,
        amount: @data[:total_collected]
      }

      # WP
      accounting_code = ReadOnlyAccountingCode.find(@branch_accounting_code_settings.withdraw_payment_accounting_code_id)

      @data[:totals].each do |o|
        if o[:record_type] == "WP"
          @total_wp = o[:amount].to_f
        elsif o[:record_type] == "SAVINGS" and o[:key] == Settings.default_savings_key
          @total_savings = o[:amount].to_f
        end
      end

      if @total_wp > @total_savings
        diff  = (@total_wp - @total_savings)

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: diff
        }
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []

      # loan_payments
      @loan_products.each do |loan_product|
        @loan_product_accounting_codes.each do |o|
          if loan_product.id == o.loan_product_id
            receivable_ac = ReadOnlyAccountingCode.where(id: o.receivable_accounting_code_id).first
            interest_ac   = ReadOnlyAccountingCode.where(id: o.interest_receivable_accounting_code_id).first

            if receivable_ac.blank?
              raise "#{o.receivable_accounting_code_id} not found. #{o.inspect}"
            end

            if interest_ac.blank?
              raise "#{o.interest_receivable_accounting_code_id} not found. #{o.inspect}"
            end

            journal_entries << {
              accounting_code_id: receivable_ac.id,
              code: receivable_ac.code,
              name: receivable_ac.name,
              record_type: "LOAN_PAYMENT",
              loan_product_id: loan_product.id,
              receivable: true,
              interest: false,
              amount: 0.00
            }

            journal_entries << {
              accounting_code_id: interest_ac.id,
              code: interest_ac.code,
              name: interest_ac.name,
              record_type: "LOAN_PAYMENT",
              loan_product_id: loan_product.id,
              receivable: false,
              interest: true,
              amount: 0.00
            }
          end
        end
      end

      # savings (deposit)
      @savings_accounting_codes.each do |o|
        accounting_code = ReadOnlyAccountingCode.find(o.deposit_accounting_code_id)

        is_default_savings  = false
        if Settings.default_savings_key == o.savings_type
          is_default_savings = true
        end

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          record_type: "SAVINGS",
          savings_type: o.savings_type,
          is_default_savings: is_default_savings,
          amount: 0.00
        }
      end
      # savings (deposit)
      @equity_accounting_codes.each do |o|
        accounting_code = ReadOnlyAccountingCode.find(o.deposit_accounting_code_id)

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          record_type: "EQUITY",
          equity_type: o.equity_type,
          amount: 0.00
        }
      end

      # insurance
      @insurance_accounting_codes.each do |o|
        accounting_code = ReadOnlyAccountingCode.find(o.deposit_accounting_code_id)

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          record_type: "INSURANCE",
          insurance_type: o.insurance_type,
          amount: 0.00
        }
      end

      @data[:records].each do |r|
        r[:records].each do |rr|
          if rr[:record_type] == "SAVINGS" and rr[:amount].to_f > 0
            journal_entries.each_with_index do |j, i|
              if rr[:account_subtype] == j[:savings_type] and j[:record_type] == "SAVINGS"
                journal_entries[i][:amount] += rr[:amount].to_f
              end
            end

          elsif rr[:record_type] == "EQUITY" and rr[:amount].to_f > 0
            journal_entries.each_with_index do |j, i|
              if rr[:account_subtype] == j[:equity_type] and j[:record_type] == "EQUITY"
                journal_entries[i][:amount] += rr[:amount].to_f
              end
            end

          
          elsif rr[:record_type] == "INSURANCE" and rr[:amount].to_f > 0
            journal_entries.each_with_index do |j, i|
              if rr[:account_subtype] == j[:insurance_type] and j[:record_type] == "INSURANCE"
                journal_entries[i][:amount] += rr[:amount].to_f
              end
            end
          elsif rr[:record_type] == "LOAN_PAYMENT" and rr[:amount].to_f > 0
            loan      = ReadOnlyLoan.find(rr[:loan_id])
            amount    = rr[:amount].to_f
            date_paid = @collection_date

            config = {
              loan: loan,
              amount: amount,
              date_paid: date_paid
            }

            s = ::Loans::FetchPaymentStats.new(config: config).execute!

            journal_entries.each_with_index do |j, i|
              if j[:receivable] and j[:record_type] == "LOAN_PAYMENT" and j[:loan_product_id] == loan.loan_product_id and s[:principal_paid] > 0.00
                journal_entries[i][:amount] += s[:principal_paid]
              end

              if j[:interest] and j[:record_type] == "LOAN_PAYMENT" and j[:loan_product_id] == loan.loan_product_id and s[:interest_paid] > 0.00
                journal_entries[i][:amount] += s[:interest_paid]
              end
            end
          end
        end
      end

      # WP and Savings Net
      if @total_wp > 0
        journal_entries.each_with_index do |j, i|
          if j[:record_type] == "SAVINGS" and j[:is_default_savings] == true
            journal_entries[i][:amount] -= @total_wp
            
            if journal_entries[i][:amount] < 0
              journal_entries[i][:amount] = 0.00
            end
          end
        end
      end

      journal_entries
    end

    def default_particular
      if @data[:accounting_entry].present? and @data[:accounting_entry][:particular].present?
        return @data[:accounting_entry][:particular]
      else
        "Payment of Loan / Deposit of Funds - #{@center.try(:name)}"
      end
    end
  end
end
