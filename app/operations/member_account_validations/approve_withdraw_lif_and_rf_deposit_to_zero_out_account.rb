module MemberAccountValidations
  class ApproveWithdrawLifAndRfDepositToZeroOutAccount
    def initialize(config:)
      @config                             = config

      @member_account                     = @config[:member_account]
      @member                             = @config[:member]
      @date_paid                          = @config[:date_paid]
      @balance                            = @config[:balance]
      @accounting_entry_reference_number  = @config[:accounting_entry_reference_number]
      @particular                         = "Withdrawal of #{@member_account.account_subtype}"
      @amount                             = @balance

      @transaction_type                   = "withdraw"

      @account_transaction  = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: @amount,
                                transaction_type: @transaction_type,
                                transacted_at: @date_paid,
                                status: "approved"
                              )

      @data = {
        is_withdraw_payment: true,
        is_fund_transfer: false,
        is_interest: false,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        accounting_entry_reference_number: @accounting_entry_reference_number,
        beginning_balance: 0.00,
        ending_balance: 0.00
      }
    end

    def execute!
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] - @amount).round(2)

      # For equity amount computation
      if @member_account.account_subtype == Settings.life
        @member_account_data = @member_account.data.with_indifferent_access
        equity_value = @member_account_data[:equity_value].to_f

        @data[:equity_value]                = (equity_value - equity_value).round(2)
        @member_account_data[:equity_value] = (equity_value - equity_value).round(2)

        @member_account.update!(data: @member_account_data)

        # For Equity Value deposit transaction
        member     = @member_account.member
        ev_account = member.member_accounts.where(account_subtype:"Equity Value").first
        
        if ev_account.present?
          ev_balance = ev_account.balance

          account_transaction  = AccountTransaction.new(
                                    subsidiary_id: ev_account.id,
                                    subsidiary_type: "MemberAccount",
                                    amount: ev_balance.to_f,
                                    transaction_type: "withdraw",
                                    transacted_at: @date_paid,
                                    status: "approved",
                                    data: {
                                      is_withdraw_payment: false,
                                      is_fund_transfer: false,
                                      is_interest: false,
                                      is_adjustment: false,
                                      is_for_exit_age: false,
                                      is_for_loan_payments: false,
                                      accounting_entry_reference_number: nil,
                                      beginning_balance: ev_balance.to_f,
                                      ending_balance: (ev_balance.to_f - ev_balance.to_f).round(2)
                                    }
                                  )

          new_balance = (ev_balance.to_f - ev_balance.to_f).round(2)
          ev_account.update(
            balance: new_balance
          )

          account_transaction.save!
        end
      end

      # Update account balance
      new_balance = (@member_account.balance - @amount).round(2)
      @member_account.update(
        balance: new_balance
      )

      @account_transaction.data = @data

      @account_transaction.save!
    end
  end
end
