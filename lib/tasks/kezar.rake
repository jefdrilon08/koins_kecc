namespace :kezar do
  task :send_payments => :environment do
    branch_id     = ENV["BRANCH_ID"] || "3777729a-78e6-4e40-95f8-ef2e8a8a122e"
    branch        = Branch.find(branch_id)
    start_date    = ENV["START_DATE"] || Date.today - 2.month
    end_date      = ENV["END_DATE"] || Date.today
    endpoint      = ENV['KEZAR_API_SEND_PAYMENTS'] || "https://us-central1-rms-kmba.cloudfunctions.net/apiTest/payment/batch/upload"

    account_type      = "INSURANCE"
    account_subtypes  = ["Life Insurance Fund", "Retirement Fund"]

    account_transactions = AccountTransaction.select(
      "members.identification_number, account_transactions.transacted_at, account_transactions.amount, member_accounts.account_subtype, account_transactions.id, branches.name AS branch_name"
    ).joins(
      "INNER JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id INNER JOIN members ON members.id = member_accounts.member_id INNER JOIN branches ON branches.id = member_accounts.branch_id"
    ).where(
      "member_accounts.account_type = ? AND member_accounts.account_subtype IN (?) AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ? AND member_accounts.branch_id = ?",
      account_type,
      account_subtypes,
      start_date,
      end_date,
      branch.id
    )

    puts "Uploading #{account_transactions.size} transactions..."

    records = account_transactions.map{ |o|
      {
        memberNumber: o.identification_number,
        amountPaid: o.amount,
        branch: o.branch_name,
        datePlacedPayment: o.transacted_at.strftime("%Y-%m-%d"),
        paymentType: o.account_subtype,
        paymentRefNo: o.id,
        paymentChannel: "Bank Transfer",
        orDate: o.transacted_at.strftime("%Y-%m-%d"),
        description: "test",
        externalRef: o.id
      }
    }

    puts records.to_json

    payload = records

    puts "Posting to #{endpoint}..."

    result  = HTTParty.post(
                endpoint,
                body: payload.to_json,
                :headers => { 'Content-Type' => 'application/json' }
              )

    puts(result)
  end
end
