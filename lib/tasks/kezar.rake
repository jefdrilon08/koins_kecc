namespace :kezar do
  task :send_payments => :environment do
    branch        = Branch.find(ENV["BRANCH_ID"])
    start_date    = ENV["START_DATE"] || Date.today - 1.month
    end_date      = ENV["END_DATE"] || Date.today

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
        extranlRef: o.id
      }
    }

    payload = records

    puts "Posting to #{ENV['KEZAR_API_SEND_PAYMENTS']}..."

    result  = HTTParty.post(
                ENV['KEZAR_API_SEND_PAYMENTS'],
                body: payload.to_json,
                :headers => { 'Content-Type' => 'application/json' }
              )

    print(result)
  end
end
