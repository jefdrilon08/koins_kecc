module InsuranceFundTransferCollections
  class ApproveInsuranceFundTransferHash
    def initialize(config:)
      @config                     = config
      @date_paid                  = @config[:date_paid]
      @insurance_fund_transfer    = @config[:insurance_fund_transfer]
      @user                       = @config[:user]
      @particular                 = @config[:particular]
      @amount                     = @insurance_fund_transfer[:amount].try(:to_f).round(2)
      @transaction_type           = "deposit"
      @member_account             = MemberAccount.find(@insurance_fund_transfer[:member_account_id])

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
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        beginning_balance: 0.00,
        ending_balance: 0.00
      }
    end

    def execute!
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

      # For equity amount computation
      if @member_account.account_subtype == Settings.life
        @member_account_data = @member_account.data.with_indifferent_access
        equity_value = @member_account_data[:equity_value]

        @data[:equity_value]                = ((@amount / 2) + equity_value).round(2)
        @member_account_data[:equity_value] = ((@amount / 2) + equity_value).round(2)

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
