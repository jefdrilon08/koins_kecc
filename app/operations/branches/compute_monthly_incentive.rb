module Branches
  class ComputeMonthlyIncentive
    def initialize(config:)
      @config = config
      @year   = @config[:year]
      @month  = @config[:month]
      @branch = @config[:branch]
      @as_of  = Date.new(@year, @month, -1)

      @ds_repayment_rate  = DataStore.repayment_rates.where(
                              "meta->>'branch_id' = ?",
                              @branch.id
                            ).order(
                              "CAST(meta->>'as_of' AS DATE) ASC"
                            ).last

      @ds_monthly_new_and_resigned  = DataStore.monthly_new_and_resigned.where(
                                        "meta->>'branch_id' = ?",
                                        @branch.id
                                      ).order(
                                        "CAST(meta->>'as_of' AS DATE) ASC"
                                      ).last

      # Check if we have the necessary information

      @rr_date  = @ds_repayment_rate.data.with_indifferent_access
      @officers = @rr_date.map{ |o| o[:officer] }.uniq

      @data = {
        year: @year,
        month: @month,
        as_of: @as_of,
        officers: [],
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        records: []
      }
    end

    def execute!
    end
  end
end
