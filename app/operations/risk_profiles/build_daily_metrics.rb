module RiskProfiles
  class BuildDailyMetrics
    def initialize(config:)
      @as_off = config[:test]
      #raise @as_off.inspect

    end
    def execute!
        
        @a = []
        DailyBranchMetric.where(as_of: @as_off).map{ |b| b}.each do |d|
          sum_member = d[:data]["loaners"]["total"].to_i + d[:data]["pure_savers"]["total"] + d[:data]["active_members"]["total"] + d[:data]["inactive_member"]["total"]
          par_rate = d[:par] * 100
          @a << {
                branch_id: d[:branch_id ],
                total_mebers: sum_member,
                portfolio: d[:portfolio],
                par_rate: par_rate,
                par_amount: d[:par_amount]

               }
        end
        @a

    end
  end
end
