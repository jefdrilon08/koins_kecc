module DailyBranchMatric
  class FetchData
    def initialize
      @data = {}
    end

    def execute!
      @record = DailyBranchMetric.where(as_of: "2022-09-30")
    end
  end

end
