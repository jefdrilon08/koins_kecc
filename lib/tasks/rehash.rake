namespace :rehash do
  task :member_account => :environment do
    member_account  = MemberAccount.find(ENV['ID'])
    puts "Rehashing member_account #{member_account.id}..."

    ::MemberAccounts::Rehash.new(
      member_account: member_account
    ).execute!

    puts "Done."
  end

  task :member_account_by_branch => :environment do
    members         = Member.active.where(
                        branch_id: ENV['BRANCH_ID']
                      )

    member_accounts = MemberAccount.where(member_id: members.pluck(:id))
    member_accounts.each do |member_account|  
      puts "Rehashing member_account #{member_account.id}..."

      ::MemberAccounts::Rehash.new(
        member_account: member_account
      ).execute!
    end

    puts "Done."
  end

  task :member_accounts => :environment do
    member_accounts = MemberAccount.where.not(member_id: nil)
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
    #loans = Loan.active_or_paid
    loans = Loan.where(id: "a810c835-ee22-4326-9b9a-7a20533ee043")

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
