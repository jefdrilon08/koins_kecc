module Adjustments
  module SubsidiaryAdjustments
    class ApproveDepositHash
      def initialize(config:)
        @config = config

        @date_paid      = @config[:date_paid]
        @amount         = @config[:amount]
        @particular     = @config[:particular]
        @member_account = @config[:member_account]
        @user           = @config[:user]

        @transaction_type = "deposit"
      end

      def execute!
        @account_transaction  = AccountTransaction.new(
                                  subsidiary_id: @member_account.id,
                                  subsidiary_type: "MemberAccount",
                                  amount: @amount,
                                  transaction_type: @transaction_type,
                                  transacted_at: @date_paid,
                                  status: "approved"
                                )

        @data = {
          is_withdraw_payment: false,
          is_fund_transfer: false,
          is_interest: false,
          is_adjustment: true,
          is_for_exit_age: false,
          is_for_loan_payments: false,
          accounting_entry_reference_number: nil,
          beginning_balance: 0.00,
          ending_balance: 0.00
        }

        # Compute beginning and ending balance
        @data[:beginning_balance] = @member_account.balance.round(2)
        @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

        # For equity amount computation
        if @member_account.account_subtype == Settings.life
          @member_account_data = @member_account.data.with_indifferent_access
          equity_value = @member_account_data[:equity_value].to_f

          @data[:equity_value]                = ((@amount.to_f / 2) + equity_value).round(2)
          @member_account_data[:equity_value] = ((@amount.to_f / 2) + equity_value).round(2)

          @member_account.update!(data: @member_account_data)
        end

        # Update account balance
        new_balance = (@member_account.balance + @amount).round(2)
        @member_account.update(
          balance: new_balance
        )

        @account_transaction.data = @data

        @account_transaction.save!
      end
    end
  end
end
