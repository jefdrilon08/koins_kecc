module Accounting
  class FetchBeginningBalances
    def initialize(config:)
      @config = config

      @accounting_fund  = @config[:accounting_fund]
      @branch           = @config[:branch]
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]

      @category = @config[:category]

      if @category == "ASSETS"
        @accounting_codes = AccountingCode.assets
      elsif @category == "LIABILITIES"
        @accounting_codes = AccountingCode.liabilities
      elsif @category == "EQUITIES"
        @accounting_codes = AccountingCode.equities
      elsif @category == "EXPENSES"
        @accounting_codes = AccountingCode.expenses
      elsif @category == "INCOME"
        @accounting_codes = AccountingCode.income
      elsif @category == "FUND BALANCE"
        @accounting_codes = AccountingCode.fund_balance
      else
        raise "Invalid category #{@category}"
      end

      @data = {
        start_date: @start_date,
        end_date: @end_date
      }
    end

    def execute!
      if @accounting_fund.present?
        dr_hash = AccountingEntry
                    .joins(journal_entries: :accounting_code)
                    .where(
                      "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                      "DR",
                      @start_date,
                      @accounting_codes.pluck(:id),
                      @branch.id,
                      @accounting_fund.id
                    )
                    .where.not("accounting_entries.book = ?", "MISC")
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")

        cr_hash = AccountingEntry
                    .joins(journal_entries: :accounting_code)
                    .where(
                      "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                      "CR",
                      @start_date,
                      @accounting_codes.pluck(:id),
                      @branch.id,
                      @accounting_fund.id
                    )
                    .where.not("accounting_entries.book = ?", "MISC")
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      else
        dr_hash = AccountingEntry
                    .joins(journal_entries: :accounting_code)
                    .where(
                      "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                      "DR",
                      @start_date,
                      @accounting_codes.pluck(:id),
                      @branch.id
                    )
                    .where.not("accounting_entries.book = ?", "MISC")
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")

        cr_hash = AccountingEntry
                    .joins(journal_entries: :accounting_code)
                    .where(
                      "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                      "CR",
                      @start_date,
                      @accounting_codes.pluck(:id),
                      @branch.id
                    )
                    .where.not("accounting_entries.book = ?", "MISC")
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      end

      @data[:dr_hash] = dr_hash
      @data[:cr_hash] = cr_hash

      @data
    end
  end
end
