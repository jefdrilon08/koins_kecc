namespace :rehash do
  
  task :member_account_rehash => :environment do
    id = ENV['ID']
    beginning_balance = 0
    ending_balance = 0

    a =  AccountTransaction.where(subsidiary_id: id).order(:transacted_at)

    a.each do |f|
    
      beginning_balance = beginning_balance
      
      if f.deposit?
        ending_balance = beginning_balance + f.amount
      else
        ending_balance = beginning_balance - f.amount                 
      end 
      data = f.data.with_indifferent_access
      data[:beginning_balance] = beginning_balance
      data[:ending_balance] = ending_balance 
      f.update(data: data)
                            
      beginning_balance = ending_balance
    end
    
    MemberAccount.find(id).update(balance: a.last.data.with_indifferent_access[:ending_balance] )

  end

  task :member_account => :environment do
    member_account  = MemberAccount.find(ENV['ID'])
    puts "Rehashing member_account #{member_account.id}..."

    ::MemberAccounts::Rehash.new(
      member_account: member_account
    ).execute!

    puts "Done."
  end

  task :member_account_by_branch => :environment do
    member_accounts = MemberAccount.where(branch_id: ENV['BRANCH_ID'])
    member_accounts.each do |member_account|  
      puts "Rehashing member_account #{member_account.id}..."

      ::MemberAccounts::Rehash.new(
        member_account: member_account
      ).execute!
    end

    puts "Done."
  end

  task :member_accounts => :environment do
    member_accounts = MemberAccount.all
    size            = member_accounts.size

    if ENV["ACCOUNT_TYPE"].present?
      member_accounts = member_accounts.where(account_type: ENV["ACCOUNT_TYPE"])
    end

    member_accounts.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Rehasing member account #{o.id}... #{progress}%%")
      sleep(0.1)

      ::MemberAccounts::Rehash.new(
        member_account: o
      ).execute!
    end

    puts ""
    puts "Done."
  end

  task :loans => :environment do
    loans = Loan.active_or_paid

    if ENV['BRANCH_ID'].present?
      branch  = Branch.find(ENV['BRANCH_ID'])
      loans   = loans.where(branch_id: branch.id)

      puts "Rehashing loans for branch #{branch.name}"
    end

    size  = loans.size


    loans.each_with_index do |loan, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Rehasing loan #{loan.id}... #{progress}%%")
      sleep(0.1)

      ::Loans::FixAmort.new(
        loan: loan
      ).execute!

#      ::Loans::Reage.new(
#        loan: loan,
#        approved_by: "SYSTEM"
#      ).execute!
    end

    puts ""
    puts "Done."
  end
end
