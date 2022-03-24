namespace :kezar do
  task :send_payments => :environment do
    branch        = Branch.find(ENV["BRANCH_ID"])
    start_date    = ENV["START_DATE"] || Date.today - 1.month
    end_date      = ENV["END_DATE"] || Date.today

    account_type      = "INSURANCE"
    account_subtypes  = ["Life Insurance Fund", "Retirement Fund"]

    account_transactions = []

    account_transactions = AccountTransaction.joins(
      "INNER JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id"
    ).where(
      "member_accounts.account_type = ? AND member_accounts.account_subtype IN (?) AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ?",
      account_type,
      account_subtypes,
      start_date,
      end_date
    ).limit(5)
  end
end
