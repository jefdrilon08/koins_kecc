module ClosingRecords
  class FetchDataStores
    attr_accessor :records,
                  :branch,
                  :record_type,
                  :closing_date

    def initialize(branch:, record_type:, closing_date:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date.to_date

      # TRIAL_BALANCE --> GENERAL_LEDGER
      if @record_type == "TRIAL_BALANCE"
        @record_type = "GENERAL_LEDGER"
      end

      @month  = @closing_date.month
      @year   = @closing_date.year

      @records = []
    end

    def execute!
      if ["TRIAL_BALANCE", "GENERAL_LEDGER", "SOA_FUNDS", "SOA_EXPENSES", "SOA_LOANS"].include?(@record_type)
        @records = ReadOnlyDataStore.done.where(
          "meta->>'data_store_type' = ? AND meta->>'branch_id' = ? AND EXTRACT(month FROM end_date) = ? AND EXTRACT(year FROM end_date) = ?",
          @record_type,
          @branch.id,
          @month,
          @year
        ).order("updated_at DESC").map{ |o|
          path = "#"

          if @record_type == "TRIAL_BALANCE"
            path = "/accounting/trial_balances/#{o.id}"
          else @record_type == "GENERAL_LEDGER"
            path = "/accounting/general_ledgers/#{o.id}"
          end

          {
            id: o.id,
            label: "#{o.start_date.strftime("%b %d %Y")} - #{o.end_date.strftime("%b %d %Y")} (Updated: #{o.updated_at.strftime("%b %d %Y")}) [#{o.meta['data_store_type']}]",
            type: @record_type,
            closing_date: @closing_date.strftime("%b %d %Y"),
            path: path
          }
        }
      elsif ["BALANCE_SHEET", "INCOME_STATEMENT"].include?(@record_type)
        @records = ReadOnlyDataStore.done.where(
          "meta->>'data_store_type' = ? AND meta->>'branch_id' = ? AND meta->>'month' = ? AND meta->>'year' = ?",
          @record_type,
          @branch.id,
          @month.to_s,
          @year.to_s
        ).order("updated_at DESC").map{ |o|
          path = "#"

          if @record_type == "BALANCE_SHEET"
            path = "/accounting/balance_sheets/#{o.id}"
          elsif @record_type == "INCOME_STATEMENT"
            path = "/accounting/income_statements/#{o.id}"
          end

          {
            id: o.id,
            label: "#{o.meta['month']} #{o.meta['year']} (Updated: #{o.updated_at.strftime("%b %d %Y")}) [#{o.meta['data_store_type']}]",
            type: @record_type,
            closing_date: @closing_date.strftime("%b %d %Y"),
            path: path
          }
        }
      else
        @records = ReadOnlyDataStore.done.where(
          "meta->>'data_store_type' = ? AND meta->>'branch_id' = ? AND EXTRACT(month FROM as_of) IN (?) AND EXTRACT(year FROM as_of) = ?",
          @record_type,
          @branch.id,
          [@month,@month + 1],
          @year
        ).order("updated_at DESC").map{ |o|
          path = "#"

          {
            id: o.id,
            label: "#{o.as_of.strftime("%b %d %Y")} (Updated: #{o.updated_at.strftime("%b %d %Y")} [#{o.meta['data_store_type']}])",
            type: @record_type,
            closing_date: @closing_date.strftime("%b %d %Y"),
            path: path
          }
        }
      end

      @records
    end
  end
end
