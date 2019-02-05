namespace :adjust do
  task :perform_deposit => :environment do
    date_paid         = ENV['DATE_PAID'].to_date
    user              = User.find(ENV['USER_ID'])
    particular        = ENV['PARTICULAR']
    member            = Member.find(ENV['MEMBER_ID']) 
    amount            = ENV['AMOUNT'].to_f
    record_type       = ENV['RECORD_TYPE']
    account_subtype   = ENV['ACCOUNT_SUBTYPE']
    member_account_id = ENV['MEMBER_ACCOUNT_ID']
    enabled           = true

    config  = {
      date_paid: date_paid,
      deposit: {
        amount: amount,
        enabled: enabled,
        member_id: member_id,
        record_type: record_type,
        account_subtype: account_subtype,
        member_account_id: member_account_id
      },
      member: member,
      user: user,
      particular: particular
    }

    puts "Performing deposit for account #{member_account_id}"

    ::DepositCollections::ApproveDepositHash.new(
      config: config
    ).execute!
  end

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
