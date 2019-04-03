module MemberAccounts
  module TimeDeposit
    class ApplyLockInPeriod
      def initialize(config:)
        @config                   = config
        @member_account           = @config[:member_account]
        @start_date               = @config[:start_date]
        @number_of_days           = @config[:number_of_days].to_i
        @monthly_interest_rate    = @config[:monthly_interest_rate]
        @default_interest_rate    = @config[:default_interest_rate]
        @amount                   = @config[:amount]

        if @member_account.data.blank?
          @data = {}
        else
          @data = @member_account.data.with_indifferent_access
        end

        @lock_in_period = {
          start_date: @start_date,
          end_date: nil,
          number_of_days: @number_of_days,
          monthly_interest_rate: @monthly_interest_rate,
          default_interest_rate: @default_interest_rate,
          amount: @amount
        }
      end

      def execute!
        save_lock_in_period!
      end

      private

      def perform_deposit!
      end

      def save_lock_in_period!
        # Compute end date = start date + num days
        @lock_in_period[:end_date] = @start_date + @number_of_days.days

        # Save lock in period to member_account's data
        @data[:lock_in_period] = @lock_in_period

        # Check if previous_lock_in_periods exist: present?
        # If false, put previous_lock_in_periods: blank?
        if @data[:previous_lock_in_periods].blank?
          @data[:previous_lock_in_periods] = []
        end

        @member_account.update!(data: @data)
      end
    end
  end
end
