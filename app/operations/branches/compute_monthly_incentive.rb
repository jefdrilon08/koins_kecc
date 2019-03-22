module Branches
  class ComputeMonthlyIncentive
    def initialize(config:)
      @config = config
      @year   = @config[:year]
      @month  = @config[:month]
      @branch = @config[:branch]
      @as_of  = Date.new(@year, @month, -1)

      @ds_repayment_rate
      @ds_monthly_new_and_resigned

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
