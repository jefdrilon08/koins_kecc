namespace :save do
  task :save_insurance_member_account_transactions => :environment do
    filename  = "member-account-transactions-v2.json"

    if ENV['FILENAME'].present?
      filename  = ENV['FILENAME']
    end

    full_path = "#{Rails.root}/db_backup/#{filename}"


    data  = {
      account_transactions: []
    }

    # INSURANCE
    if ENV['BRANCH_ID'].present?
      branch = Branch.find(ENV['BRANCH_ID'])
      insurance_accounts = InsuranceAccount.where(branch_id: branch.id)
      insurance_accounts = insurance_accounts.joins(:member).where("members.status IN (?)", ["active", "resigned", "pending"])
    else
      insurance_accounts = InsuranceAccount.joins(:member).where("members.status IN (?)", ["active", "resigned", "pending"])
    end

    insurance_account_transactions  = InsuranceAccountTransaction.approved.where(insurance_account_id: insurance_accounts.pluck(:id))

    if ENV['DATE_OFFSET'].present?
      insurance_account_transactions = insurance_account_transactions.where("DATE(created_at) >= ?", ENV['DATE_OFFSET'].to_date)
    end

    if ENV['START_DATE'].present? && ENV['END_DATE'].present?
      insurance_account_transactions = insurance_account_transactions.where("DATE(created_at) >= ? AND DATE(created_at) <= ?", ENV['START_DATE'].to_date, ENV['END_DATE'].to_date)
    end

    insurance_account_transactions.each do |o|
      data[:account_transactions] << o.to_version_2_hash
    end


    puts "Saving file to #{full_path}..."

    File.write(full_path, JSON.pretty_generate(data))

    puts "Done!"
  end

  task :save_insurance_member_accounts => :environment do
    filename  = "member-accounts-v2.json"

    if ENV['FILENAME'].present?
      filename  = ENV['FILENAME']
    end

    full_path = "#{Rails.root}/db_backup/#{filename}"

    data  = {
      member_accounts: []
    }


    # INSURANCE
    if ENV['BRANCH_ID'].present?
      branch = Branch.find(ENV['BRANCH_ID'])
      insurance_accounts = InsuranceAccount.where(branch_id: branch.id)
      insurance_accounts = insurance_accounts.joins(:member).where("members.status IN (?)", ["active", "resigned", "pending"])
    else
      insurance_accounts = InsuranceAccount.joins(:member).where("members.status IN (?)", ["active", "resigned", "pending"])
    end

    if ENV['DATE_OFFSET'].present?
      insurance_accounts = insurance_accounts.where("DATE(created_at) >= ?", ENV['DATE_OFFSET'].to_date)
    end

    insurance_accounts.each do |o|
      data[:member_accounts] << o.to_version_2_hash
    end

    puts "Saving file to #{full_path}..."

    File.write(full_path, JSON.pretty_generate(data))

    puts "Done!"
  end
end