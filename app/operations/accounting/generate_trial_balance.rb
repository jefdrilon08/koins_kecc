module Accounting
  class GenerateTrialBalance
    def initialize(config:)
      @config     = config
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]

      @year = @end_date.year
      
      @accounting_codes = AccountingCode.all.order("code ASC")

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        accounting_codes: @accounting_codes,
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
      compute_beginning!
      compute_current!
      compute_ending!

      @data
    end

    private

    def compute_beginning!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where("accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year FROM date_posted) = ?", 'DR', @start_date, @year)
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where("accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted < ? AND extract(year FROM date_posted) = ?", 'CR', @start_date, @year)
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f
        end

        if accounting_code.debit_entry?
          dr_amount = dr_amount - cr_amount
          cr_amount = 0.00
        elsif accounting_code.credit_entry?
          cr_amount = cr_amount - dr_amount
          dr_amount = 0.00
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

    def compute_current!
      dr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where("accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND extract(year FROM date_posted) = ?", 'DR', @start_date, @end_date, @year)
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      cr_hash = AccountingEntry
                  .includes(journal_entries: :accounting_code)
                  .where("accounting_entries.status = 'approved' AND journal_entries.post_type = ? AND date_posted >= ? AND date_posted <= ? AND extract(year FROM date_posted) = ?", 'CR', @start_date, @end_date, @year)
                  .group("journal_entries.accounting_code_id")
                  .sum("journal_entries.amount")

      @accounting_codes.each do |accounting_code|
        dr_amount = 0.00
        cr_amount = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          dr_amount = dr_hash[accounting_code.id.to_s].to_f
        end

        if cr_hash.has_key? accounting_code.id.to_s
          cr_amount = cr_hash[accounting_code.id.to_s].to_f
        end

        if accounting_code.debit_entry?
          dr_amount = dr_amount - cr_amount
          cr_amount = 0.00
        elsif accounting_code.credit_entry?
          cr_amount = cr_amount - dr_amount
          dr_amount = 0.00
        end

        entry = {
          accounting_code: accounting_code,
          dr_amount: dr_amount,
          cr_amount: cr_amount
        }

        @data[:current_entries] << entry

        @data[:total_current_debit] += dr_amount
        @data[:total_current_credit] += cr_amount
      end
    end

    def compute_ending!
      @accounting_codes.each_with_index do |accounting_code, i|
        dr_amount = @data[:beginning_entries][i][:dr_amount] + @data[:current_entries][i][:dr_amount]
        cr_amount = @data[:beginning_entries][i][:cr_amount] + @data[:current_entries][i][:cr_amount]

        if accounting_code.debit_entry?
          dr_amount = dr_amount - cr_amount
          cr_amount = 0.00
        elsif accounting_code.credit_entry?
          cr_amount = cr_amount - dr_amount
          dr_amount = 0.00
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
    end
  end
end
