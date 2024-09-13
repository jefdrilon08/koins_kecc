module ClosingRecords
  class FetchClosingRecords
    attr_accessor :records,
                  :branch,
                  :closing_date

    def initialize(branch:, closing_date:)
      @branch       = branch
      @closing_date = closing_date.to_date

      @month  = @closing_date.month
      @year   = @closing_date.year

      @records = []
    end

    def execute!
      results = AdministrationBranchClosingRecord.where(
        "branch_id = ? AND EXTRACT(month FROM closing_date) = ? AND EXTRACT(year FROM closing_date) = ?",
        @branch.id,
        @month,
        @year
      )

      results.each do |o|
        ds = DataStore.find(o.data_store_id).meta["data_store_type"]
        if o.record_type == ds or o.record_type == "TRIAL_BALANCE"
          stats = "done"
        else
          stats = "invalid"
        end

        path = "#"
        case o.record_type 
        when "TRIAL_BALANCE"
          path = "/accounting/trial_balances/#{o.data_store_id}"
        when "GENERAL_LEDGER"
          path = "/accounting/general_ledgers/#{o.data_store_id}"
        when "REPAYMENT_RATES"
          path = "/data_stores/repayment_rates/#{o.data_store_id}"
        when "BALANCE_SHEET"
          path = "/accounting/balance_sheets/#{o.data_store_id}"
        when "INCOME_STATEMENT"
          path = "/accounting/income_statements/#{o.data_store_id}"
        when "SOA_FUNDS"
          path = "/data_stores/soa_funds/#{o.data_store_id}"
        when "SOA_EXPENSES"
          path = "/data_stores/soa_expenses/#{o.data_store_id}"
        when "SOA_LOANS"
          path = "/data_stores/soa_loans/#{o.data_store_id}"
        when "MANUAL_AGING"
          path = "/data_stores/manual_aging/#{o.data_store_id}"
        when "PERSONAL_FUNDS"
          path = "/data_stores/personal_funds/#{o.data_store_id}"
        when "MEMBER_COUNTS"
          path = "/data_stores/member_counts/#{o.data_store_id}"
        when "MONTHLY_NEW_AND_RESIGNED"
          path = "/data_stores/monthly_new_and_resigned/#{o.data_store_id}"
        end

        @records << {
          type:           o.record_type,
          closing_date:   o.closing_date.strftime("%b %d %Y"),
          status:         stats,
          path:           path,
          data_store_id:  o.data_store_id,
          data:           o.data
        }
      end

      current_record_types = results.pluck(:record_type)

      ReadOnlyAdministrationBranchClosingRecord::RECORD_TYPES.each do |record_type|
        if !current_record_types.include?(record_type)
          @records << {
            type:         record_type,
            closing_date: "N/A",
            status:       "pending",
            path:         "#"
          }
        end
      end

      @records
    end
  end
end
