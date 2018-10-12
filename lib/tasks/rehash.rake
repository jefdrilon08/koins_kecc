namespace :rehash do
  task :member_accounts => :environment do
    member_accounts = MemberAccount.all
    size            = member_accounts.size

    member_accounts.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Rehasing member account #{o.id}... #{progress}%%")

      ::MemberAccounts::Rehash.new(
        member_account: o
      ).execute!
    end

    puts ""
    puts "Done."
  end

  task :loans => :environment do
    loans = Loan.active_or_paid
    size  = loans.size

    loans.each_with_index do |loan, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Rehasing loan #{loan.id}... #{progress}%%")

      ::Loans::Reage.new(
        loan: loan,
        approved_by: "SYSTEM"
      ).execute!
    end

    puts ""
    puts "Done."
  end
end
