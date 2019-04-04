module MemberAccounts
  module TimeDeposit
    class DepositInterest
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]

        @data         = @member_account.data
        @amount       = data[:lock_in_period][:amount]
        @current_date = Date.today

        @monthly_interest_rate  = @data[:lock_in_period][:monthly_interest_rate]
        @start_date             = @data[:lock_in_period][:start_date].to_date
        @end_date               = @data[:lock_in_period][:end_date].to_date
        @number_of_days         = @data[:lock_in_period][:number_of_days].to_i
      end

      def execute!
        # Determine correct monthly_interest_rate 
        if @current_date < @end_date
          @monthly_interest_rate  = @data[:lock_in_period][:default_monthly_interest_rate]
        end

         # Computation
      end
    end
  end
end
