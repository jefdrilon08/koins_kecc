module MemberAccountValidations
  class ApproveRfMemberDeposit
    def initialize(config:)
      @config                             = config

      @member_account_validation_record   = @config[:member_account_validation_record]
      @member                             = @member_account_validation_record.member
      @date_paid                          = @config[:date_paid]
      @accounting_entry_reference_number  = @config[:accounting_entry_reference_number]
      @particular                         = "Interest of Retirement Fund per annum"
      @amount                             = @config[:amount]

      @member_account                     = MemberAccount.where(
                                                        member_id: @member.id,
                                                        account_type: "INSURANCE",
                                                        account_subtype: "Retirement Fund"
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
        is_withdraw_payment: true,
        is_fund_transfer: false,
        is_interest: true,
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
