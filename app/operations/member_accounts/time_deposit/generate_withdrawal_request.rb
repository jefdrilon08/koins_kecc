module MemberAccounts
  module TimeDeposit
    class GenerateWithdrawalRequest
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]
        @branch         = @config[:branch]
        @user           = @config[:user]

        @member = @member_account.member

        if @member_account.account_subtype != "Time Deposit"
          raise "Account #{@member_account.id} is not a Time Deposit account"
        end

        if @branch.blank?
          raise "Branch not found"
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

        # Accounting code: Cash in bank (DR)
        @accounting_code_cash_in_bank = AccountingCode.where(
                                          id: Settings.branch_accounting_codes.select{ |o|
                                                o.branch_id == @branch.id
                                              }.first.try(:cash_in_bank_accounting_code_id)
                                        ).first

        if @accounting_code_cash_in_bank.blank?
          raise "Accounting code cash in bank not found"
        end

        # Accounting code: Interest expense
        @accounting_code_interest_expense = AccountingCode.where(
                                              id: Settings.branch_accounting_codes.select{ |o|
                                                    o.branch_id == @branch.id
                                                  }.first.try(:interest_expense_accounting_code_id)
                                            ).first

        if @accounting_code_interest_expense.blank?
          raise "Accounting code interest expense not found"
        end

        # Accounting code: Time deposit
        @accounting_code_time_deposit = AccountingCode.where(
                                          id: Settings.branch_accounting_codes.select{ |o|
                                                o.branch_id == @branch.id
                                              }.first.try(:time_deposit_accounting_code_id)
                                        ).first

        if @accounting_code_time_deposit.blank?
          raise "Accounting code time deposit not found"
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
            book: "JVB",
            date_prepared: @current_date.strftime("%B %d, %Y"),
            company_name: Settings.company_name,
            company_address: Settings.company_address,
            branch: @branch.to_s.upcase,
            prepared_by: @user.full_name,
            particular: default_particular,
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
            status: "display",
            data: {
              or_number: "",
              ar_number: ""
            }
          }
        }
      end

      def execute!
        build_withdrawal_data!
        build_accounting_entry!

        @data
      end

      private

      def default_particular
        "Time deposit withdrawal"
      end

      def build_withdrawal_data!
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
      end

      def build_accounting_entry!
        @data[:accounting_entry][:debit_journal_entries]  = build_debit_journal_entries!
        @data[:accounting_entry][:credit_journal_entries] = build_credit_journal_entries!

        # Build journal entries
        @data[:accounting_entry][:debit_journal_entries].each do |j|
          @data[:accounting_entry][:journal_entries] << {
            id: "",
            post_type: "DR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: j[:name],
            code: j[:code],
            amount: j[:amount]
          }
        end

        @data[:accounting_entry][:credit_journal_entries].each do |j|
          @data[:accounting_entry][:journal_entries] << {
            id: "",
            post_type: "CR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: j[:name],
            code: j[:code],
            amount: j[:amount]
          }
        end
      end

      def build_debit_journal_entries!
        journal_entries = []

        # Debit interest expense
        if @data[:interest_amount].to_f > 0
          journal_entries << {
            accounting_code_id: @accounting_code_interest_expense.id,
            code: @accounting_code_interest_expense.code,
            name: @accounting_code_interest_expense.name,
            amount: @data[:interest_amount]
          }
        end

        # Debit savings deposit time deposit
        if @data[:amount_to_withdraw].to_f > 0
          journal_entries << {
            accounting_code_id: @accounting_code_time_deposit.id,
            code: @accounting_code_time_deposit.code,
            name: @accounting_code_time_deposit.name,
            amount: @data[:amount_to_withdraw]
          }
        end

        journal_entries
      end

      def build_credit_journal_entries!
        journal_entries = []

        # Credit savings deposit time deposit
        if @data[:interest_amount].to_f > 0
          journal_entries << {
            accounting_code_id: @accounting_code_time_deposit.id,
            code: @accounting_code_time_deposit.code,
            name: @accounting_code_time_deposit.name,
            amount: @data[:interest_amount]
          }
        end

        # Credit cash in bank (whole amount)
        if @data[:amount_to_withdraw].to_f > 0
          journal_entries << {
            accounting_code_id: @accounting_code_cash_in_bank.id,
            code: @accounting_code_cash_in_bank.code,
            name: @accounting_code_cash_in_bank.name,
            amount: @data[:amount_to_withdraw]
          }
        end

        journal_entries
      end
    end
  end
end
