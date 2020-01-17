module Accounting
  class FetchBeginningBalances
    def initialize(config:)
      @config = config

      @accounting_fund  = @config[:accounting_fund]
      @branch           = @config[:branch]
      @start_date       = @config[:start_date].try(:to_date)
      @end_date         = @config[:end_date].try(:to_date)

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

      @latest_closing_record  = DataStore.year_end_closings.where(
                                  "status = ? AND meta->>'branch_id' = ?",
                                  "closed",
                                  @branch.id
                                ).order(
                                  "created_at ASC"
                                ).last

      if @accounting_fund.present?
        @latest_closing_entry = AccountingEntry.year_end_closing.where(accounting_fund_id: @accounting_fund.id).order("date_posted DESC").first
      else
        @latest_closing_entry = AccountingEntry.year_end_closing.order("date_posted DESC").first
      end

      if @latest_closing_entry.present?
        @closing_date = @latest_closing_entry.date_posted
      end

      if @latest_closing_record.present?
        @closing_date = @latest_closing_record.meta["closing_date"].to_date
      end

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        beginning_entries: [],
        total_beginning_debit: 0.00,
        total_beginning_credit: 0.00
      }
    end

    def execute!
      if ["ASSETS", "LIABILITIES", "EQUITIES", "FUND BALANCE"].include?(@category)
        compute_overall!
      elsif ["INCOME", "EXPENSES"].include?(@category)
        compute_yearly!
      else
        raise "Invalid category #{@category}"
      end

      @data[:total_beginning_debit]   = @data[:total_beginning_debit].round(2)
      @data[:total_beginning_credit]  = @data[:total_beginning_credit].round(2)

      @data
    end

    def compute_yearly!
      if @accounting_fund.present?
        dr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year from date_posted) = ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                          "DR",
                          @start_date,
                          @start_date.year,
                          @accounting_codes.pluck(:id),
                          @branch.id,
                          @accounting_fund.id
                        )

        if @closing_date.present? and @start_date <= @closing_date and @end_date <= @closing_date
#          dr_entries  = dr_entries.where.not(
#                          "accounting_entries.data->>'is_closing_record' = ? AND accounting_entries.date_posted = ?",
#                          "true",
#                          @closing_date
#                        )
          dr_entries  = dr_entries.where("accounting_entries.data->'is_closing_record' IS NULL")
        end

        dr_hash = dr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
        
        cr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year from date_posted) = ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                          "CR",
                          @start_date,
                          @start_date.year,
                          @accounting_codes.pluck(:id),
                          @branch.id,
                          @accounting_fund.id
                        )

        if @closing_date.present? and @start_date < @closing_date and @end_date < @closing_date
#          cr_entries  = cr_entries.where.not(
#                          "accounting_entries.data->>'is_closing_record' = ? AND accounting_entries.date_posted = ?",
#                          "true",
#                          @closing_date
#                        )
          cr_entries  = cr_entries.where("accounting_entries.data->'is_closing_record' IS NULL")
        end

        cr_hash = cr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      else
        dr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year from date_posted) = ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                          "DR",
                          @start_date,
                          @start_date.year,
                          @accounting_codes.pluck(:id),
                          @branch.id
                        )

        if @closing_date.present? and @start_date < @closing_date and @end_date < @closing_date
#          dr_entries  = dr_entries.where.not(
#                          "accounting_entries.data->>'is_closing_record' = ? AND accounting_entries.date_posted = ?",
#                          "true",
#                          @closing_date
#                        )
          dr_entries  = dr_entries.where("accounting_entries.data->'is_closing_record' IS NULL")
        end

        dr_hash = dr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")

        cr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year from date_posted) = ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                          "CR",
                          @start_date,
                          @start_date.year,
                          @accounting_codes.pluck(:id),
                          @branch.id
                        )

        if @closing_date.present? and @start_date <= @closing_date and @end_date <= @closing_date
#          cr_entries  = cr_entries.where.not(
#                          "accounting_entries.data->>'is_closing_record' = ? AND accounting_entries.date_posted = ?",
#                          "true",
#                          @closing_date
#                        )
          cr_entries  = cr_entries.where("accounting_entries.data->'is_closing_record' IS NULL")
        end

        cr_hash = cr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      end

      @accounting_codes.each do |accounting_code|
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
    end

    def compute_overall!
      if @accounting_fund.present?
        dr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                          "DR",
                          @start_date,
                          @accounting_codes.pluck(:id),
                          @branch.id,
                          @accounting_fund.id
                        )

        dr_hash = dr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")

        cr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ? AND accounting_entries.accounting_fund_id = ?",
                          "CR",
                          @start_date,
                          @accounting_codes.pluck(:id),
                          @branch.id,
                          @accounting_fund.id
                        )

        cr_hash = cr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      else
        dr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                          "DR",
                          @start_date,
                          @accounting_codes.pluck(:id),
                          @branch.id
                        )

        dr_hash = dr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")


        cr_entries  = AccountingEntry
                        .joins(journal_entries: :accounting_code)
                        .where(
                          "accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND accounting_codes.id IN (?) AND accounting_entries.branch_id = ?",
                          "CR",
                          @start_date,
                          @accounting_codes.pluck(:id),
                          @branch.id
                        )

        cr_hash = cr_entries
                    .group("journal_entries.accounting_code_id")
                    .sum("journal_entries.amount")
      end

      @accounting_codes.each do |accounting_code|
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
    end
  end
end
