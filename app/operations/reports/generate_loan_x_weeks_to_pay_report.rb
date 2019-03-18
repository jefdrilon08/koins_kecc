module Reports
  class GenerateLoanXWeeksToPayReport
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date) || Date.today
      @x      = @config[:x].try(:to_i) || 4
      @loan   = @config[:loan]

      @date_until = (@as_of + @x.weeks).to_date
    end

    def execute!
      ::Reports::GenerateLoanRepaymentReport.new(
        config: {
          loan: @loan,
          as_of: @as_of
        }
      ).execute!
    end
  end
end
