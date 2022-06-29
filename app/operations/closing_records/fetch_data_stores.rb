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
        @records = ReadOnlyDataStore.where(
          "meta->>'data_store_type' = ? AND meta->>'branch_id' = ? AND EXTRACT(month FROM end_date) = ? AND EXTRACT(year FROM end_date) = ?",
          @record_type,
          @branch.id,
          @month,
          @year
        ).order("updated_at DESC").map{ |o|
          {
            id: o.id,
            label: "#{o.start_date.strftime("%b %d %Y")} - #{o.end_date.strftime("%b %d %Y")} (Updated: #{o.updated_at.strftime("%b %d %Y")})"
          }
        }
      else
        @records = ReadOnlyDataStore.done.where(
          "meta->>'data_store_type' = ? AND meta->>'branch_id' = ? AND EXTRACT(month FROM as_of) = ? AND EXTRACT(year FROM as_of) = ?",
          @record_type,
          @branch.id,
          @month,
          @year
        ).order("updated_at DESC").map{ |o|
          {
            id: o.id,
            label: "#{o.as_of.strftime("%b %d %Y")} (Updated: #{o.updated_at.strftime("%b %d %Y")})"
          }
        }
      end

      @records
    end
  end
end
