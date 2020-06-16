module MemberAccountValidations
  class ApproveEquityInterestDeposit
    def initialize(config:)
      @config                             = config

      @member_account_validation_record   = @config[:member_account_validation_record]
      @date_paid                          = @config[:date_paid]
      @accounting_entry_reference_number  = @config[:accounting_entry_reference_number]
      @member                             = @member_account_validation_record.member
      @particular                         = "Interest of Equity per week"
      @amount                             = @member_account_validation_record.equity_interest


      @member_account                     = MemberAccount.where(
                                                        member_id: @member.id,
                                                        account_type: "INSURANCE",
                                                        account_subtype: "Life Insurance Fund"
                                                        ).first

      @transaction_type = "deposit"

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
        is_interest: true,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        accounting_entry_reference_number: @accounting_entry_reference_number,
        beginning_balance: 0.00,
        ending_balance: 0.00,
        equity_value: 0.00
      }
    end

    def execute!
      # Compute beginning and ending balance
      @data[:beginning_balance] = @member_account.balance.round(2)
      @data[:ending_balance]    = (@data[:beginning_balance] + @amount).round(2)

      # For equity value data
      @member_account_data      = @member_account.data.with_indifferent_access
      equity_value              = @member_account_data[:equity_value]
      @data[:equity_value]      = equity_value.round(2)

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
