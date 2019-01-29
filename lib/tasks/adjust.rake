namespace :adjust do
  task :perform_deposits => :environement do
    deposit_collection    = DepositCollection.find(ENV['ID'])
    user                  = User.find(ENV['USER_ID'])
    data_deposits         = deposit_collection.deposits
    data_accounting_entry = deposit_collection.accounting_entry
    date_approved         = deposit_collection.date_approved

    data_deposits.each do |o|
      config  = {
        date_paid: date_approved,
        deposit: o,
        member: Member.find(o[:member_id]),
        user: user,
        particular: data_accounting_entry[:particular]
      }

      puts "Performing deposit for account #{o[:member_account_id]}"

      ::DepositCollections::ApproveDepositHash.new(
        config: config
      ).execute!
    end

    puts "Done."
  end

  task :perform_withdrawals => :environment do
    withdrawal_collection = WithdrawalCollection.find(ENV['ID'])
    user                  = User.find(ENV['USER_ID'])
    data_withdrawals      = withdrawal_collection.withdrawals
    data_accounting_entry = withdrawal_collection.accounting_entry
    date_approved         = withdrawal_collection.date_approved

    data_withdrawals.each do |o|
      config  = {
        date_paid: date_approved,
        withdrawal: o,
        member: Member.find(o[:member_id]),
        user: user,
        particular: data_accounting_entry[:particular]
      }

      puts "Performing withdrawal for account #{o[:member_account_id]}"

      ::WithdrawalCollections::ApproveWithdrawalHash.new(
        config: config
      ).execute!
    end

    puts "Done."
  end
end
