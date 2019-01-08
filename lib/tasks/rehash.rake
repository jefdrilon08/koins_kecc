namespace :rehash do
  task :member_accounts => :environment do
    member_accounts = MemberAccount.all
    size            = member_accounts.size

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

#      ::Loans::FixAmort.new(
#        loan: loan
#      ).execute!

      ::Loans::Reage.new(
        loan: loan,
        approved_by: "SYSTEM"
      )
    end

    puts ""
    puts "Done."
  end
end
