module Accounting
  class FetchTrialBalance
    def initialize(config:)
      @config           = config
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]
      @branch           = @config[:branch]
      @accounting_fund  = @config[:accounting_fund]
      @accounting_codes = {}
    end

    def categories
      %i[assets liabilities equities income expenses fund_balance]
    end

    def execute!
      data = {
        start_date:             @start_date,
        end_date:               @end_date,
        branch:                 @branch,
        entries:                [],
        total_beginning_debit:  0.00,
        total_beginning_credit: 0.00,
        total_current_debit:    0.00,
        total_current_credit:   0.00,
        total_ending_debit:     0.00,
        total_ending_credit:    0.00
      }

      categories.each do |category|
        accounting_codes = ReadOnlyAccountingCode.send(category)

        data[:"#{category}_beginning"] = build_entries(category: category, phase: :beginning, accounting_codes: accounting_codes)
        data[:"#{category}_current"]   = build_entries(category: category, phase: :current, accounting_codes: accounting_codes)
        data[:"#{category}_ending"]    = build_entries(category: category, phase: :ending, accounting_codes: accounting_codes)

        data.fetch(:"#{category}_beginning")[:entries].each_with_index do |entry, i|
          entry = {
            id:               entry.fetch(:accounting_code_id),
            name:             entry.fetch(:accounting_code_name),
            code:             entry.fetch(:accounting_code_code),
            beginning_debit:  entry.fetch(:debit),
            beginning_credit: entry.fetch(:credit),
            current_debit:    data.fetch(:"#{category}_current")[:entries][i][:debit],
            current_credit:   data.fetch(:"#{category}_current")[:entries][i][:credit],
            ending_debit:     data.fetch(:"#{category}_ending")[:entries][i][:debit],
            ending_credit:    data.fetch(:"#{category}_ending")[:entries][i][:credit],
          }

          if [
            entry[:beginning_debit],
            entry[:beginning_credit],
            entry[:current_debit],
            entry[:current_credit],
            entry[:ending_debit],
            entry[:ending_credit],
          ].any? { |e| e > 0 }
            data[:entries] << entry
          end
        end

        data[:total_beginning_debit]  += data.fetch(:"#{category}_beginning").fetch(:total_debit)
        data[:total_beginning_credit] += data.fetch(:"#{category}_beginning").fetch(:total_credit)
        data[:total_current_debit]    += data.fetch(:"#{category}_current").fetch(:total_debit)
        data[:total_current_credit]   += data.fetch(:"#{category}_current").fetch(:total_credit)
        data[:total_ending_debit]     += data.fetch(:"#{category}_ending").fetch(:total_debit)
        data[:total_ending_credit]    += data.fetch(:"#{category}_ending").fetch(:total_credit)
      end

      data[:entries] << {
        id:               "",
        name:             "TOTAL",
        beginning_debit:  data[:total_beginning_debit],
        beginning_credit: data[:total_beginning_credit],
        current_debit:    data[:total_current_debit],
        current_credit:   data[:total_current_credit],
        ending_debit:     data[:total_ending_debit],
        ending_credit:    data[:total_ending_credit]
      }

      data
    end

    private

    def set_closing_date(phase)
      latest_closing_record = ReadOnlyDataStore
        .year_end_closings
        .where("status = ? AND meta->>'branch_id' = ?", "closed", @branch.id)
        .order("created_at DESC")
        .first

      if latest_closing_record.present?
        @closing_date = latest_closing_record.meta["closing_date"].to_date
      end

      if phase == :beginning
        if @accounting_fund.present?
          latest_closing_entry = ReadOnlyAccountingEntry
            .year_end_closing
            .where(accounting_fund_id: @accounting_fund.id)
            .order("date_posted DESC")
            .first
        else
          latest_closing_entry = ReadOnlyAccountingEntry
            .year_end_closing
            .order("date_posted DESC")
            .first
        end

        if latest_closing_entry.present?
          @closing_date = latest_closing_entry.date_posted
        end
      end
    end

    def build_entries(category:, phase:, accounting_codes:)
      is_yearly = case category
                  when :assets       then false
                  when :liabilities  then false
                  when :equities     then false
                  when :fund_balance then false
                  when :income       then true
                  when :expenses     then true
                  else raise "Invalid category, given #{category}"
                  end

      set_closing_date(phase)

      compute_totals(category, phase, accounting_codes: accounting_codes, is_yearly: is_yearly)
    end

    def closing_date_is_within_range?
      @closing_date.present? && (@start_date <= @closing_date) && (@end_date <= @closing_date)
    end

    def group_by_code_and_amount(phase, entries, is_yearly:)
      is_beginning_and_overall = !is_yearly && phase == :beginning
      if closing_date_is_within_range? && !is_beginning_and_overall
        entries = entries.where("accounting_entries.data->'is_closing_record' IS NULL")
      end

      entries.group("journal_entries.accounting_code_id").sum("journal_entries.amount")
    end

    def filter_entries(category, phase, post_type, accounting_fund_id = nil, is_yearly:)
      entries = ReadOnlyAccountingEntry
        .joins(journal_entries: :accounting_code)
        .where(
          status: "approved",
          branch_id: @branch.id,
          journal_entries: { post_type: post_type },
          accounting_codes: { category: category.to_s.upcase.gsub("_", " ") },
        )

      entries = entries.where(accounting_fund_id: accounting_fund_id) if accounting_fund_id

      case phase
      when :beginning
        entries = entries.where("accounting_entries.date_posted < ?", @start_date)
        entries = entries.where("EXTRACT(YEAR FROM accounting_entries.date_posted) = ?", @start_date.year) if is_yearly
      when :current
        entries = entries.where("accounting_entries.date_posted >= ? AND accounting_entries.date_posted <= ?", @start_date, @end_date)
        entries = entries.where("EXTRACT(YEAR FROM accounting_entries.date_posted) = ?", @start_date.year) if is_yearly
      when :ending
        entries = entries.where("date_posted <= ?", @end_date)
        entries = entries.where("EXTRACT(YEAR FROM accounting_entries.date_posted) = ?", @end_date.year) if is_yearly
      else
        raise "Invalid phase, given #{phase}"
      end
      entries
    end

    def compute_totals(category, phase, accounting_codes:, is_yearly:)
      dr_entries = filter_entries(category, phase, "DR", @accounting_fund.try(:id), is_yearly: is_yearly)
      cr_entries = filter_entries(category, phase, "CR", @accounting_fund.try(:id), is_yearly: is_yearly)

      dr_hash = group_by_code_and_amount(phase, dr_entries, is_yearly: is_yearly)
      cr_hash = group_by_code_and_amount(phase, cr_entries, is_yearly: is_yearly)

      total_debit = 0.00
      total_credit = 0.00

      entries = accounting_codes.map do |accounting_code|
        debit = 0.00
        credit = 0.00

        if dr_hash.has_key? accounting_code.id.to_s
          debit = dr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if cr_hash.has_key? accounting_code.id.to_s
          credit = cr_hash[accounting_code.id.to_s].to_f.round(2)
        end

        if phase != :current
          if accounting_code.debit_entry?
            debit = (debit - credit).round(2)
            credit = 0.00

            if debit < 0
              credit = debit * -1
              debit = 0.00
            end
          elsif accounting_code.credit_entry?
            credit = (credit - debit).round(2)
            debit = 0.00

            if credit < 0
              debit = credit * -1
              credit = 0.00
            end
          end
        end

        total_debit += debit
        total_credit += credit

        {
          accounting_code_id: accounting_code.id,
          accounting_code_name: accounting_code.name,
          accounting_code_code: accounting_code.code,
          debit: debit,
          credit: credit,
        }
      end

      {
        total_debit: total_debit.round(2),
        total_credit: total_credit.round(2),
        entries: entries,
      }
    end
  end
end
