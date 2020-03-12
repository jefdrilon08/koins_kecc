namespace :diagnosis do
  task :member_accounts => :environment do
    branch          = Branch.find(ENV['BRANCH_ID'])
    account_subtype = ENV['ACCOUNT_SUBTYPE']
    batch_size      = ENV['BATCH_SIZE'].try(:to_id) || 100
    repair          = ENV['REPAIR'].present? ? true : false

    invalid_accounts = []

    member_accounts = MemberAccount.where(
                        "branch_id = ? AND account_subtype = ?",
                        branch.id,
                        account_subtype
                      )

    member_accounts.each do |a|
      puts "Scanning #{a.id}..."
      balance = 0.00
      valid   = true

      AccountTransaction.where(
        subsidiary_id: a.id
      ).order(
        "transacted_at ASC, updated_at ASC"
      ).each do |t|
        if balance != t.data["beginning_balance"].to_d.round(2)
          valid = false
        end

        if t.deposit?
          balance += t.amount
        elsif t.withdraw?
          balance -= t.amount
        end

        balance = balance.round(2)

        if balance != t.data["ending_balance"].to_d.round(2)
          valid = false
        end
      end

      if !valid
        invalid_accounts << a
      end
    end

    size  = invalid_accounts.size

    if size > 0
      puts "Found #{size} accounts..."
      invalid_accounts.each_with_index do |o, i|
        if o.savings?
          domain = "savings_accounts"
        elsif o.insurance?
          domain = "insurance_accounts"
        elsif o.equity?
          domain = "equity_accouts"
        else
          raise "Invalid account_type #{o.account_type}"
        end

        puts "#{i+1} / #{size}: #{repair ? "Repairing " : ""}http://#{ENV['HOST']}/#{domain}/#{o.id}"

        if repair
          ::MemberAccounts::Rehash.new(
            member_account: o
          ).execute!

          sleep(0.1)
        end
      end
    else
      puts "No invalid accouts found!"
    end
  end
end
