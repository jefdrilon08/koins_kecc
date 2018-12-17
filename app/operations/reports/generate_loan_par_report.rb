module Reports
  class GenerateLoanParReport
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date) || Date.today
      @loan   = @config[:loan]
    end

    def execute!
    end
  end
end
