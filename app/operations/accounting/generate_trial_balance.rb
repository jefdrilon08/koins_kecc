module Accounting
  class GenerateTrialBalance
    def initialize(config:)
      @config     = config
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @branch     = @config[:branch]

      @year = @end_date.year
      
      @accounting_codes                                     = AccountingCode.all.order("code ASC")
      @income_and_expenses_accounting_codes                 = @accounting_codes.income_and_expenses
      @assets_and_liabilities_and_equities_accounting_codes = @accounting_codes.assets_and_liabilities_and_equities
      @fund_balance_accounting_codes                        = @accounting_codes.fund_balance

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        accounting_codes: @accounting_codes,
        income_and_expenses_accounting_codes: @income_and_expenses_accounting_codes,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        beginning_entries: [],
        current_entries: [],
        ending_entries: [],
        total_beginning_debit: 0.00,
        total_beginning_credit: 0.00,
        total_current_debit: 0.00,
        total_current_credit: 0.00,
        total_ending_debit: 0.00,
        total_ending_credit: 0.00
      }
    end

    def execute!
      compute_beginning_assets_and_liabilities_and_equities!
      compute_current_assets_and_liabilities_and_equities!

      compute_beginning_income_and_expenses!
      compute_current_income_and_expenses!

      compute_beginning_fund_balances!
      compute_current_fund_balances!

      compute_ending!

      # Flatten Total
#      result  = (@data[:total_beginning_debit] - @data[:total_beginning_credit]).abs
#      @data[:total_beginning_debit]   = result
#      @data[:total_beginning_credit]  = result

      @data
    end

    private

    def compute_beginning_fund_balances!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date,
                    @fund_balance_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date,
                    @fund_balance_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @fund_balance_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if accounting_code.debit_entry?
          dr_amount = (dr_amount - cr_amount).round(2)
          cr_amount = 0.00

          if dr_amount < 0
            cr_amount = dr_amount * -1
            dr_amount = 0.00
          end
        elsif accounting_code.credit_entry?
          cr_amount = (cr_amount - dr_amount).round(2)
          dr_amount = 0.00

          if cr_amount < 0
            dr_amount = cr_amount * -1
            cr_amount = 0.00
          end
        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:beginning_entries] << entry

        @data[:total_beginning_debit] += dr_amount
        @data[:total_beginning_credit] += cr_amount
      end

      @data[:total_beginning_debit]   = @data[:total_beginning_debit].round(2)
      @data[:total_beginning_credit]  = @data[:total_beginning_credit].round(2)
    end

    def compute_beginning_assets_and_liabilities_and_equities!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date,
                    @assets_and_liabilities_and_equities_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date,
                    @assets_and_liabilities_and_equities_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @assets_and_liabilities_and_equities_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if accounting_code.debit_entry?
          dr_amount = (dr_amount - cr_amount).round(2)
          cr_amount = 0.00

          if dr_amount < 0
            cr_amount = dr_amount * -1
            dr_amount = 0.00
          end
        elsif accounting_code.credit_entry?
          cr_amount = (cr_amount - dr_amount).round(2)
          dr_amount = 0.00

          if cr_amount < 0
            dr_amount = cr_amount * -1
            cr_amount = 0.00
          end
        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:beginning_entries] << entry

        @data[:total_beginning_debit] += dr_amount
        @data[:total_beginning_credit] += cr_amount
      end

      @data[:total_beginning_debit]   = @data[:total_beginning_debit].round(2)
      @data[:total_beginning_credit]  = @data[:total_beginning_credit].round(2)
    end

    def compute_beginning_income_and_expenses!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND extract(year FROM date_posted) = ? AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date,
                    @income_and_expenses_accounting_codes.pluck(:id),
                    @year,
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND extract(year FROM date_posted) = ? AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date,
                    @income_and_expenses_accounting_codes.pluck(:id),
                    @year,
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @income_and_expenses_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if accounting_code.debit_entry?
          dr_amount = (dr_amount - cr_amount).round(2)
          cr_amount = 0.00

          if dr_amount < 0
            cr_amount = dr_amount * -1
            dr_amount = 0.00
          end
        elsif accounting_code.credit_entry?
          cr_amount = (cr_amount - dr_amount).round(2)
          dr_amount = 0.00

          if cr_amount < 0
            dr_amount = cr_amount * -1
            cr_amount = 0.00
          end
        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:beginning_entries] << entry

        @data[:total_beginning_debit] += dr_amount
        @data[:total_beginning_credit] += cr_amount
      end

      @data[:total_beginning_debit]   = @data[:total_beginning_debit].round(2)
      @data[:total_beginning_credit]  = @data[:total_beginning_credit].round(2)
    end

    def compute_current_fund_balances!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date, 
                    @end_date,
                    @fund_balance_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date, 
                    @end_date,
                    @fund_balance_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @fund_balance_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

#        if accounting_code.debit_entry?
#          dr_amount = dr_amount - cr_amount
#          cr_amount = 0.00
#
#          if dr_amount < 0
#            cr_amount = dr_amount * -1
#            dr_amount = 0.00
#          end
#        elsif accounting_code.credit_entry?
#          cr_amount = cr_amount - dr_amount
#          dr_amount = 0.00
#
#          if cr_amount < 0
#            dr_amount = cr_amount * -1
#            cr_amount = 0.00
#          end
#        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:current_entries] << entry

        @data[:total_current_debit] += dr_amount
        @data[:total_current_credit] += cr_amount
      end

      @data[:total_current_debit]   = @data[:total_current_debit].round(2)
      @data[:total_current_credit]  = @data[:total_current_credit].round(2)
    end

    def compute_current_assets_and_liabilities_and_equities!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date, 
                    @end_date,
                    @assets_and_liabilities_and_equities_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date, 
                    @end_date,
                    @assets_and_liabilities_and_equities_accounting_codes.pluck(:id),
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @assets_and_liabilities_and_equities_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

#        if accounting_code.debit_entry?
#          dr_amount = dr_amount - cr_amount
#          cr_amount = 0.00
#
#          if dr_amount < 0
#            cr_amount = dr_amount * -1
#            dr_amount = 0.00
#          end
#        elsif accounting_code.credit_entry?
#          cr_amount = cr_amount - dr_amount
#          dr_amount = 0.00
#
#          if cr_amount < 0
#            dr_amount = cr_amount * -1
#            cr_amount = 0.00
#          end
#        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:current_entries] << entry

        @data[:total_current_debit] += dr_amount
        @data[:total_current_credit] += cr_amount
      end

      @data[:total_current_debit]   = @data[:total_current_debit].round(2)
      @data[:total_current_credit]  = @data[:total_current_credit].round(2)
    end

    def compute_current_income_and_expenses!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND extract(year FROM date_posted) = ? AND accounting_entries.branch_id = ?", 
                    'DR', 
                    @start_date, 
                    @end_date,
                    @income_and_expenses_accounting_codes.pluck(:id),
                    @year,
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where(
                    "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND accounting_codes.id IN (?) AND extract(year FROM date_posted) = ? AND accounting_entries.branch_id = ?", 
                    'CR', 
                    @start_date, 
                    @end_date,
                    @income_and_expenses_accounting_codes.pluck(:id),
                    @year,
                    @branch.id
                  )
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @income_and_expenses_accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

#        if accounting_code.debit_entry?
#          dr_amount = dr_amount - cr_amount
#          cr_amount = 0.00
#
#          if dr_amount < 0
#            cr_amount = dr_amount * -1
#            dr_amount = 0.00
#          end
#        elsif accounting_code.credit_entry?
#          cr_amount = cr_amount - dr_amount
#          dr_amount = 0.00
#
#          if cr_amount < 0
#            dr_amount = cr_amount * -1
#            cr_amount = 0.00
#          end
#        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:current_entries] << entry

        @data[:total_current_debit] += dr_amount
        @data[:total_current_credit] += cr_amount
      end

      @data[:total_current_debit]   = @data[:total_current_debit].round(2)
      @data[:total_current_credit]  = @data[:total_current_credit].round(2)
    end

    def compute_ending!
      @accounting_codes.each_with_index do |accounting_code, i|
        beginning_dr_amount = @data[:beginning_entries][i][:dr_amount]
        beginning_cr_amount = @data[:beginning_entries][i][:cr_amount]

        current_dr_amount = @data[:current_entries][i][:dr_amount]
        current_cr_amount = @data[:current_entries][i][:cr_amount]

        dr_amount = beginning_dr_amount + current_dr_amount
        cr_amount = beginning_cr_amount + current_cr_amount

        if accounting_code.debit_entry?
          dr_amount = (dr_amount - cr_amount).round(2)
          cr_amount = 0.00

          if dr_amount < 0
            cr_amount = dr_amount * -1
            dr_amount = 0.00
          end
        elsif accounting_code.credit_entry?
          cr_amount = (cr_amount - dr_amount).round(2)
          dr_amount = 0.00

          if cr_amount < 0
            dr_amount = cr_amount * -1
            cr_amount = 0.00
          end
        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:ending_entries] << entry

        @data[:total_ending_debit] += dr_amount
        @data[:total_ending_credit] += cr_amount
      end

      @data[:total_ending_debit]  = @data[:total_ending_debit].round(2)
      @data[:total_ending_credit] = @data[:total_ending_credit].round(2)
    end
  end
end
