module MembershipPaymentCollections
  class ApproveInsurancePaymentHash
    def initialize(config:)
      @config             = config
      @date_paid          = @config[:date_paid]
      @insurance_payment  = @config[:insurance_payment]
      @user               = @config[:user]
      @particular         = @config[:particular]

      #raise @insurance_payment.inspect
      @amount             = @insurance_payment[:amount].try(:to_f).round(2)

      @transaction_type = "deposit"

      @member_account = MemberAccount.find(@insurance_payment[:member_account_id])

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
        accounting_entry_reference_number: nil,
        beginning_balance: 0.00,
        ending_balance: 0.00
      }
    end

    def execute!
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

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
