module MemberAccounts
  module TimeDeposit
    class GenerateWithdrawalRequest
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]
        @branch         = @config[:branch]

        @member = @member_account.member

        if @member_account.account_subtype != "Time Deposit"
          raise "Account #{@member_account.id} is not a Time Deposit account"
        end

        @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

        @account_transactions = AccountTransaction.approved_member_account_transactions(
                                  @member_account.id,
                                  @current_date
                                )

        if @account_transactions.size == 0
          raise "Account #{@member_account.id} has no transactions"
        end

        @balance  = @member_account.balance.to_f.round(2)

        @latest_transaction = @account_transactions.last
        @start_date         = @latest_transaction.transacted_at.to_date

        @data = @latest_transaction.data.with_indifferent_access

        @latest_ending_balance  = @data[:ending_balance].to_f.round(2)
        @interest = 0.00

        @lock_in_period                     = @data[:lock_in_period]
        @interest_rate_per_month            = @lock_in_period[:interest_rate]
        @premature_interest_rate_per_month  = @lock_in_period[:premature_interest_rate] || 0.0016
        @num_days                           = @lock_in_period[:num_days]
        @num_months                         = @lock_in_period[:num_months]

        @maturity_date  = @start_date + @num_months.months

        @data = {
          branch: {
            id: @branch.id,
            name: @branch.name
          },
          account_transaction_id: @latest_transaction.id,
          balance: @latest_ending_balance,
          interest_rate_per_month: @interest_rate_per_month,
          premature_interest_rate_per_month: @premature_interest_rate_per_month,
          start_date: @start_date,
          end_date: @current_date,
          withdrawal_date: @current_date,
          num_days_outstanding: 0,
          interest_amount: 0.00,
          lock_in_period: @lock_in_period,
          accounting_entry: {
          }
        }
      end

      def execute!
        @data[:num_days_outstanding]  = (@current_date - @start_date).to_i

        if @current_date < (@start_date + 1.month)
          @data[:interest_rate_per_month] = 0.00
        elsif @current_date < @maturity_date
          @data[:interest_amount] = ((@data[:premature_interest_rate_per_month] * @data[:num_days_outstanding]) / 30) * @data[:balance]
        elsif @current_date >= @maturity_date
          @data[:interest_rate_per_month] = @interest_rate_per_month
          @data[:interest_amount]         = @lock_in_period[:expected_interest]
        end

        @data[:interest_amount]     = @data[:interest_amount].round(2)
        @data[:amount_to_withdraw]  = @data[:balance] + @data[:interest_amount]

        @data
      end
    end
  end
end
