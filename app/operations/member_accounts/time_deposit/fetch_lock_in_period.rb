module MemberAccounts
  module TimeDeposit
    class FetchLockInPeriod
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]
        @branch         = @member_account.branch

        @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

        @account_transactions = AccountTransaction.approved_member_account_transactions(
                                  @member_account.id,
                                  @current_date
                                )

        @latest_transaction = @account_transactions.last

        @data = {
        }
      end

      def execute!
        if @latest_transaction.present? and @latest_transaction.deposit?
          lock_in_period  = @latest_transaction.data.with_indifferent_access[:lock_in_period]

          @data[:num_days]          = lock_in_period[:num_days]
          @data[:start_date]        = @latest_transaction.transacted_at.to_date
          @data[:maturity_date]     = @latest_transaction.transacted_at.to_date + @data[:num_days].days
          @data[:interest_rate]     = lock_in_period[:interest_rate]
          @data[:expected_interest] = lock_in_period[:expected_interest]
        else
          @data = false
        end

        @data
      end
    end
  end
end
