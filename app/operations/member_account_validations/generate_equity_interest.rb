module MemberAccountValidations
  class GenerateEquityInterest
    def initialize(lif_member_account:, resignation_date:, equity_interest_implementation_date:)
      @equity_interest_implementation_date = equity_interest_implementation_date
      @resignation_date                    = resignation_date.to_date
      @lif_member_account                  = lif_member_account
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

      @weekly_payment                      = 7.50  

      @amount                              = 0.00
      @data                                = {}

      @data[:equity_interest]  = []

      @num_weeks = ((@resignation_date - @equity_interest_implementation_date).to_i)/7
      # TODO: Change this to parameter/settings
      # @interest_rate      = 0.01
      # @weekly             = 0.0000961
      @interest_rate_weekly = 0.00019230769

      @equity_interest   = {}
    end

    def execute!
      running_balance = 0.00
      running_interest = 0.00

      # For weekly computation
      @num_weeks.times do |i|
        running_balance       = @lif_50_percent + running_interest + @weekly_payment
        tmp                   = {}
        c                     = i + 1
        tmp[:weekly_index]     = c
        tmp[:running_balance] = running_balance
        tmp[:interest]        = (running_balance * @interest_rate_weekly).round(2)
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
