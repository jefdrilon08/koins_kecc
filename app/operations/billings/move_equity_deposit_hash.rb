module Billings
  class MoveEquityDepositHash
    def initialize(config:)
      @config     = config
      @date_paid  = @config[:date_paid]
      @member_account_id    = @config[:member_account_id]
      @user       = @config[:user]
      @particular = @config[:particular]
      @amount     = @config[:amount].try(:to_f).round(2)

      @transaction_type = "deposit"

      @member_account = MemberAccount.find(@member_account_id)

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

      config = {
        user: @user,
        member_account_id: @member_account.id,
        amount: @amount
      }

      accounting_entry_data = ::Billings::BuildAccountingEntryForAutoTransfer.new(config: config).execute!
      
      #post to books
      
      config  = {
        accounting_entry_data: accounting_entry_data,
        user: @user
      }

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: config
                          ).execute!
      
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }


      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!

     
      @accounting_entry
      raise @accounting_entry.inspect
    end
  end
end
