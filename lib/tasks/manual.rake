namespace :manual do
  task :deposit => :environment do
    dait_paid         = ENV['DATE_PAID'].to_date
    user_id           = ENV['USER_ID']
    member_account_id = ENV['MEMBER_ACCOUNT_ID']
    amount            = ENV['AMOUNT'].to_f.round(2)
    is_interest       = ENV['IS_INTEREST'].present? ? true : false
    transaction_type  = ENV['TRANSACTION_TYPE']

    member_account  = MemberAccount.find(member_account_id)
    member          = member_account.member
    user            = User.find(user_id)

    account_transaction = AccountTransaction.new(
                            subsidiary_id: member_account_id,
                            subsidiary_type: 'MemberAccount',
                            amount: amount,
                            transaction_type: transaction_type,
                            transacted_at: date_paid,
                            status: 'approved'
                          )

    data  = {
      is_withdraw_payment: false,
      is_fund_transfer: false,
      is_interest: is_interest,
      is_adjustment: false,
      is_for_exit_age: false,
      is_for_loan_payments: false,
      accounting_entry_reference_number: nil,
      beginning_balance: 0.00,
      ending_balance: 0.00
    }

    # Compute beginning and ending balance
    data[:beginning_balance]  = member_account.balance.round(2)
    data[:ending_balance]     = (data[:beginning_balance] + amount).round(2)

    # Update account balance
    new_balance = (member_account.balance + amount).round(2)
    member_account.update(
      balance: new_balance
    )

    account_transaction.data = data

    account_transaction.save!
  end
end
