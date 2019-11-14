module MemberAccountValidations
  class GenerateEquityInterest
    def initialize(lif_member_account:, resignation_date:, equity_interest_implementation_date:, lif_current_balance:)
      @equity_interest_implementation_date = equity_interest_implementation_date
      @resignation_date                    = resignation_date.to_date
      @lif_member_account                  = lif_member_account
      @lif_current_balance                 = lif_current_balance
      @lif_member_account_transactions     = AccountTransaction.personal_funds.where(
                                                    "subsidiary_id = ? AND transacted_at < ?", 
                                                    @lif_member_account.id,
                                                    @equity_interest_implementation_date
                                                    ).order("transacted_at ASC")
      if @lif_member_account_transactions.count > 1
        @lif_50_percent = @lif_member_account_transactions.last.data.with_indifferent_access[:ending_balance].try(:to_f) / 2
      else
        @lif_50_percent = 0.00
      end

      @amount_after_implementation = @lif_current_balance - (@lif_50_percent * 2)
      @num_weeks_after_implementation = @amount_after_implementation.to_i / 15

      @weekly_payment                      = 7.50
      @data                                = {}

      @num_weeks = ((@resignation_date - @equity_interest_implementation_date).to_i)/7
      # TODO: Change this to parameter/settings
      # @interest_rate      = 0.01
      # @weekly             = 0.0000961
      @interest_rate_weekly = 0.00019230769

      @data[:equity_interest]  = []
      # @data[:weekly_interest]  = []
    end

    def execute!
      tmp = {}

      @equity_interest = ((@lif_50_percent * @interest_rate_weekly) * @num_weeks).round(2)
      
      if @num_weeks_after_implementation > 0
        @equity_interest_after = ((@amount_after_implementation * @interest_rate_weekly) * @num_weeks_after_implementation).round(2)
      else
        @equity_interest_after = 0.00
      end

      tmp[:interest] = @equity_interest + @equity_interest_after

      @data[:equity_interest] << tmp


      # running_balance = 0.00
      # running_interest = 0.00
      # running_balance1 = 0.00
      # running_interest1 = 0.00

      # # For weekly computation
      # @num_weeks.times do |i|
      #   running_balance                     = @lif_50_percent + running_interest
      #   tmp                                 = {}
      #   c                                   = i + 1
      #   tmp[:weekly_index]                  = c
      #   tmp[:running_balance]               = running_balance
      #   tmp[:interest]                      = (running_balance * @interest_rate_weekly)
      #   running_interest                    += tmp[:interest].round(2)
      #   tmp[:running_balance_save_interest] = (tmp[:running_balance] + running_interest)
      #   tmp[:running_interest]              = running_interest

      #   running_balance                     += running_balance + tmp[:interest]

      #   @data[:equity_interest] << tmp
      # end

      # if @num_weeks_after_implementation > 0
      #   @num_weeks_after_implementation.times do |i|
      #     running_balance1                    = @weekly_payment + running_interest1
      #     tmp                                 = {}
      #     c                                   = i + 1
      #     tmp[:weekly_index]                  = c
      #     tmp[:running_balance]               = running_balance1
      #     tmp[:interest]                      = (running_balance1 * @interest_rate_weekly)
      #     running_interest                    += tmp[:interest].round(2)
      #     tmp[:running_balance_save_interest] = (tmp[:running_balance] + running_interest1)
      #     tmp[:running_interest]              = running_interest1

      #     running_balance1                    += running_balance1 + tmp[:interest]
  
      #     @data[:weekly_interest] << tmp
      #   end
      # else
      #   tmp = {}
      #   tmp[:running_interest] = 0.00
      #   @data[:weekly_interest] << tmp
      # end  

      @data
    end
  end
end
