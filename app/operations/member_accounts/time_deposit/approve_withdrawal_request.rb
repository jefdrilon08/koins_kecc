module MemberAccounts
  module TimeDeposit
    class ApproveWithdrawalRequest
      def initialize(config:)
        @config         = config
        @data_store     = @config[:data_store]
        @member_account = @config[:member_account]
        @user           = @config[:user]

        @branch = @member_account.branch

        @data = @data_store.data.with_indifferent_access

        @amount_to_withdraw = @data[:amount_to_withdraw]
        @interest_amount    = @data[:interest_amount]

        @current_date = @data[:end_date].to_date
      end

      def execute!
        if @interest_amount > 0
          perform_deposit!
        end

        perform_withdrawal!

        post_accounting_entry!

        @data_store.update!(
          status: "approved"
        )
      end

      private

      def perform_withdrawal!
        account_transaction = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: @amount_to_withdraw,
                                transaction_type: "withdraw",
                                transacted_at: @current_date,
                                status: "approved"
                              )
        data = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          beginning_balance: 0.00,
          ending_balance: 0.00
        }

        # Compute beginning and ending balance
        data[:beginning_balance] = @member_account.balance.round(2)
        data[:ending_balance]    = (data[:beginning_balance] - @amount_to_withdraw).round(2)

        # Update account balance
        new_balance = (@member_account.balance - @amount_to_withdraw).round(2)
        @member_account.update!(
          balance: new_balance
        )

        account_transaction.data = data

        account_transaction.save!
      end

      def perform_deposit!
        account_transaction = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: @interest_amount,
                                transaction_type: "deposit",
                                transacted_at: @current_date,
                                status: "approved"
                              )
        data = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: true,
          is_adjustment: false,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          beginning_balance: 0.00,
          ending_balance: 0.00
        }

        # Compute beginning and ending balance
        data[:beginning_balance] = @member_account.balance.round(2)
        data[:ending_balance]    = (data[:beginning_balance] + @interest_amount).round(2)

        # Update account balance
        new_balance = (@member_account.balance + @interest_amount).round(2)
        @member_account.update!(
          balance: new_balance
        )

        account_transaction.data = data

        account_transaction.save!
      end

      def post_accounting_entry!
        accounting_entry_data = @data[:accounting_entry]

        accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                              config: {
                                id: nil,
                                accounting_entry_data: accounting_entry_data,
                                user: @user
                              }
                            ).execute!

        accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                              config: {
                                accounting_entry: accounting_entry,
                                user: @user
                              }
                            ).execute!

        # Update reference number
        @data[:accounting_entry][:reference_number] = accounting_entry.reference_number
        @data[:accounting_entry][:status]           = "approved"
        @data[:accounting_entry][:approved_by]      = @user.to_s

        @data_store.update!(
          data: @data
        )
      end
    end
  end
end
