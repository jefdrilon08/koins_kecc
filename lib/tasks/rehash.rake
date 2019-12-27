namespace :rehash do
  task :loan_negative_amort => :environment do
    amort_id = ENV['ID']
  
    

    amort = AmortizationScheduleEntry.find(amort_id)
    details_sum = (amort.principal.to_f + amort.interest.to_f).to_f
  
    update_amort = amort.update(principal: details_sum, interest: 0.0, principal_paid: details_sum, interest_paid: 0.0 )

    payment_id = amort.data.with_indifferent_access[:payments][0][:payment_id]
    
    at = AccountTransaction.find(payment_id)
    at_data = at.data.with_indifferent_access
    at_data[:amort_entries][0][:principal_paid] = "#{details_sum}"
    at_data[:amort_entries][0][:interest_paid] = "0.0"
    at_data[:total_principal_paid] = "#{details_sum}"
    at_data[:total_interest_paid] = "0.0"

    at.update!(data: at_data)

    a = Loan.find(at.subsidiary_id)
    #::Loans::FixAmort.new(loan: a).execute!

    loan_amort_details =  AmortizationScheduleEntry.where("loan_id = ? and interest < ?", a,0 ).order(:due_date)
    loan_amort_details.each do |lad|
      AmortizationScheduleEntry.find(lad.id).update(principal: lad.amount_due, interest: 0.0, principal_paid: lad.amount_due, principal_balance: 0.0, interest_balance:0.0)
    end


    ::Loans::FixAmort.new(loan: a).execute!

    puts "Done."
  end


  task :member_account => :environment do
    member_account  = MemberAccount.find(ENV['ID'])
    puts "Rehashing member_account #{member_account.id}..."
    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_account.id, "approved")

    ::MemberAccounts::Rehash.new(
      member_account: member_account, account_transactions: account_transactions
    ).execute!

    puts "Done."
  end

  task :member_account_by_branch => :environment do
    members         = Member.active.where(
                        branch_id: ENV['BRANCH_ID']
                        )

    member_accounts = MemberAccount.where(member_id: members.pluck(:id))
                      
    if ENV['ACCOUNT_TYPE'].present?
      member_accounts = member_accounts.where(account_type: ENV["ACCOUNT_TYPE"])
    end

    # >>
    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_accounts.pluck(:id), "approved")

    member_accounts.each do |member_account|  
      puts "Rehashing member_account #{member_account.id}..."

      ::MemberAccounts::Rehash.new(
        member_account: member_account, account_transactions: account_transactions
      ).execute!
    end

    puts "Done."
  end

  task :member_accounts => :environment do
    member_accounts = MemberAccount.where.not(member_id: nil)
    size            = member_accounts.size

    if ENV["BRANCH_ID"].present?
      member_accounts = member_accounts.where(branch_id: ENV["BRANCH_ID"])
    end

    if ENV["ACCOUNT_TYPE"].present?
      member_accounts = member_accounts.where(account_type: ENV["ACCOUNT_TYPE"])
    end

    if ENV["ACCOUNT_SUBTYPE"].present?
      member_accounts = member_accounts.where(account_type: ENV["ACCOUNT_SUBTYPE"])
    end

    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_accounts.pluck(:id), "approved")

    member_accounts.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Rehasing member account #{o.id}... #{progress}%%")
      sleep(0.1)

      ::MemberAccounts::Rehash.new(
        member_account: o,
        account_transactions: account_transactions
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
