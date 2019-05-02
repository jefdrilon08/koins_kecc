module MemberAccountValidations
  class GenerateInterest
    def initialize(member_account:, insured_amount:, num_weeks:, num_weeks_past_due:)
      @member_account     = member_account
      @member             = @member_account.member
      @insured_amount     = insured_amount
      @num_weeks          = num_weeks
      @num_weeks_past_due = num_weeks_past_due
      @recognition_date   = @member.data.with_indifferent_access[:recognition_date].try(:to_date)
      #@current_date       = Date.today
      @amount             = 0.00
      @data               = {}

      @data[:interest_table]  = []

      # TODO: Change this to parameter/settings
      @interest_rate      = 0.02
      @weekly             = 0.01916536484

      # @member_status_data  = ::member::GeneratememberAccountStatus.new(
      #                             member_account: @member_account
      #                           ).execute!

      # @insured_amount         = @member_status_data[:insured_amount]
      # @num_weeks              = @member_status_data[:num_weeks]
      # @num_weeks_past_due     = @member_status_data[:num_weeks_past_due]

      if @num_weeks_past_due > 0 
        @num_weeks = @num_weeks - @num_weeks_past_due
      end

      # Deal with past due
      # if @num_weeks_past_due > 0
      #   @num_weeks  = @num_weeks - @num_weeks_past_due
      # end

      @num_months       = (@num_weeks.to_f / 4.0).to_i

      @periodic_payment = 5 * 4

      @current_balance  = @member_account.balance

      @interest_table   = {}

      # For weekly computation
      @periodic_p = 5
    end

    def execute!
      running_balance = 0.00
      running_interest = 0.00

      # For weekly computation
      @num_weeks.times do |i|
        running_balance                     = (@periodic_p.round(0) * (i + 1)) + running_interest
        tmp                                 = {}
        c                                   = i + 1
        tmp[:weekly_index]                  = c
        tmp[:running_balance]               = running_balance
        tmp[:interest]                      = (running_balance * @interest_rate * @weekly).round(2)
        running_interest                    += tmp[:interest].round(2)
        tmp[:running_balance_save_interest] = (tmp[:running_balance] + running_interest).round(2)
        tmp[:running_interest]              = running_interest

        running_balance                     += running_balance + tmp[:interest]

        @data[:interest_table] << tmp
      end
      
      # For monthly computation
        # @num_months.times do |i|
        #   running_balance       = @periodic_payment.round(0) * (i + 1)
        #   tmp                   = {}
        #   c                     = i + 1
        #   tmp[:month_index]     = c
        #   tmp[:running_balance] = running_balance
        #   tmp[:interest]        = (@periodic_payment * @interest_rate * (c.to_f / 12.0).to_f).round(2)
        #   running_interest      += tmp[:interest].round(2)
        #   tmp[:running_balance_save_interest] = (tmp[:running_balance] + running_interest).round(2)
        #   tmp[:running_interest] = running_interest

        #   running_balance       += running_balance + tmp[:interest]

        #   @data[:interest_table] << tmp
        # end

      @data
    end
  end
end
