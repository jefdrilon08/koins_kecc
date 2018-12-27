namespace :db do
  task :delete_branch => :environment do
    branch  = Branch.where(id: ENV['BRANCH_ID']).first

    if branch.present?
      member_ids            = Member.where(branch_id: branch.id).pluck(:id)
      loan_ids              = Loan.where(member_id: member_ids).pluck(:id)
      member_account_ids    = MemberAccount.where(member_id: member_ids).pluck(:id)
      accounting_entry_ids  = AccountingEntry.where(branch_id: branch.id).pluck(:id)
      center_ids            = Center.where(branch_id: branch.id)

      # Delete account_transactions
      puts "Deleting account_transactions for member_accounts..."
      AccountTransaction.where(subsidiary_id: member_account_ids).delete_all
      puts "Deleting account_transactions for loans..."
      AccountTransaction.where(subsidiary_id: loan_ids).delete_all

      # Delete journal_entries
      puts "Deleting journal_entries..."
      JournalEntry.where(accounting_entry_id: accounting_entry_ids).delete_all

      # Delete accounting_entries
      puts "Deleting accounting_entries..."
      AccountingEntry.where(id: accounting_entry_ids).delete_all

      # Delete amortization_schedule_entries
      puts "Deleting amortization_schedule_entries..."
      AmortizationScheduleEntry.where(loan_id: loan_ids).delete_all

      # Delete loans
      puts "Deleting loans..."
      Loan.where(id: loan_ids).delete_all

      # Delete legal_dependents
      puts "Deleting legal_dependents..."
      LegalDependent.where(member_id: member_ids).delete_all

      # Delete beneficiaries
      puts "Deleting beneficiaries..."
      Beneficiary.where(member_id: member_ids).delete_all

      # Delete billings
      puts "Deleting billings..."
      Billing.where(branch_id: branch.id).delete_all

      # Delete member_shares
      puts "Deleting member_shares..."
      MemberShare.where(member_id: member_ids).delete_all

      # Delete member_accounts
      puts "Deleting member_accounts..."
      MemberAccount.where(id: member_account_ids).delete_all
      MemberAccount.where(center_id: center_ids).delete_all

      # Delete membership_payment_records
      puts "Deleting membership_payment_records..."
      MembershipPaymentRecord.where(member_id: member_ids).delete_all

      # Delete membership_payment_collections
      puts "Deleting membership_payment_collections..."
      MembershipPaymentCollection.where(branch_id: branch.id).delete_all

      # Delete monthly_closing_collections
      puts "Deleting monthly_closing_collections..."
      MonthlyClosingCollection.where(branch_id: branch.id).delete_all

      # Delete deposit_collections
      puts "Deleting deposit_collections..."
      DepositCollection.where(branch_id: branch.id).delete_all

      # Delete withdrawal_collections
      puts "Deleting withdrawal_collections..."
      WithdrawalCollection.where(branch_id: branch.id).delete_all

      # Delete members
      puts "Deleting members..."
      Member.where(branch_id: branch.id).delete_all

      # Delete user_branches
      puts "Deleting user_branches..."
      UserBranch.where(branch_id: branch.id).delete_all

      # Delete data_stores
      puts "Deleting data_stores..."
      DataStore.where("meta->>'branch_id' = ?", branch.id).delete_all

      # Delete branch
      #branch.destroy!

    else
      puts "Branch with id #{ENV['BRANCH_ID']} not found!"
    end

    puts "Done!"
  end

  desc "Restore database"
  task :restore => :environment do
    puts "Restoring database..."

    if ::ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
      cmd = nil
      with_config do |app, host, db, user, pw|
        cmd = "PGPASSWORD=#{pw} pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{ENV['PG_BACKUP_DUMP']}"
      end
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      puts cmd
      exec cmd
    else
      puts "Invalid database adapter"
    end
  end

  task :save_accounting_codes => :environment do
    accounting_codes  = AccountingCode.all
    filename          = "accounting-codes-v2.json"
    full_path         = "#{Rails.root}/db_backup/#{filename}"

    data = { 
      accounting_codes: []
    }   

    accounting_codes.each do |o| 
      data[:accounting_codes] << o.to_version_2_hash
    end 

    puts "Saving file to #{full_path}..."

    File.write(full_path, JSON.pretty_generate(data))

    puts "Done!"
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end
end
