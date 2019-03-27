module MemberAccountValidations
  class GenerateEquityInterest
    def initialize(lif_50_percent:, resignation_date:, equity_interest_implementation_date:)
      @equity_interest_implementation_date = equity_interest_implementation_date
      @resignation_date                    = resignation_date.to_date
      @lif_50_percent                      = lif_50_percent
      @amount                              = 0.00
      @data                                = {}

      @data[:equity_interest]  = []

      @num_weeks = ((@resignation_date - @equity_interest_implementation_date).to_i)/7
      # TODO: Change this to parameter/settings
      @interest_rate      = 0.02
      @weekly             = 0.0000961

      @equity_interest   = {}
    end

    def execute!
      running_balance = 0.00
      running_interest = 0.00

      # For weekly computation
      @num_weeks.times do |i|
        running_balance       = @lif_50_percent + running_interest
        tmp                   = {}
        c                     = i + 1
        tmp[:weekly_index]     = c
        tmp[:running_balance] = running_balance
        tmp[:interest]        = (running_balance * @weekly).round(2)
        running_interest      += tmp[:interest].round(2)
        tmp[:running_balance_save_interest] = (tmp[:running_balance] + running_interest).round(2)
        tmp[:running_interest] = running_interest

        running_balance       += running_balance + tmp[:interest]

        @data[:equity_interest] << tmp
      end

      @data
    end
  end
end
