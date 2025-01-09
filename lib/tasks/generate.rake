namespace :generate do
  task :cutoff_reports => :environment do
    ProcessCutoffReports.perform_later({})
  end

  task :jef => :environment do
      a = Member.where(branch_id: "339144e0-9544-4a7a-b2d4-b500cc329034")

      puts a.map{ |g|
                        if  g.data["project_type"].present?
                          f = []
                          f << "#{g.data["project_type"]} | jef"
                          puts f
                        end

                        }
  end


  task :members_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    cmd = ::Exports::SaveMembersCsv.new(
            start_date: start_date,
            end_date: end_date
          )

    if cmd.members.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/members/process_members_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called MEMBERS API"
      else
        puts "ERROR in calling MEMBERS API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
    end
  end

  task :beneficiaries_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    cmd = ::Exports::SaveBeneficiariesCsv.new(
            start_date: start_date,
            end_date: end_date
          )

    if cmd.beneficiaries.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/members/process_beneficiaries_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called MEMBERS API"
      else
        puts "ERROR in calling MEMBERS API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
    end
  end

  task :legal_dependents_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    cmd = ::Exports::SaveLegalDependentsCsv.new(
            start_date: start_date,
            end_date: end_date
          )

    if cmd.legal_dependents.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/members/process_legal_dependents_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called MEMBERS API"
      else
        puts "ERROR in calling MEMBERS API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
    end
  end

  task :member_accounts_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    cmd = ::Exports::SaveMemberAccountsCsv.new(
            start_date: start_date,
            end_date: end_date
          )

    if cmd.member_accounts.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/insurance_accounts/process_member_accounts_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called INSURANCE API"
      else
        puts "ERROR in calling INSURANCE API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
    end
  end

  task :account_transactions_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    if ENV["BRANCH_ID"].present?
      branches = Branch.where(id: ENV["BRANCH_ID"])
    else
      branches    = Branch.all
    end

    branches.each do |branch|
      cmd = ::Exports::SaveAccountTransactionsCsv.new(
            start_date: start_date,
            end_date: end_date,
            branch: branch
          )

      # if cmd.account_transactions.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/insurance_accounts/process_account_transactions_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called INSURANCE API"
      else
        puts "ERROR in calling INSURANCE API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
      # end
    end
  end

  task :centers_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    if ENV["BRANCH_ID"].present?
      branches = Branch.where(id: ENV["BRANCH_ID"])
    else
      branches    = Branch.all
    end

    branches.each do |branch|
      cmd = ::Exports::SaveCentersCsv.new(
            start_date: start_date,
            end_date: end_date,
            branch: branch
          )

      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/centers/process_centers_file"

      response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

      if response.code.to_s == "200"
        puts "Successfully called CENTER API"
      else
        puts "ERROR in calling CENTER API"
        puts "api_url: #{api_url}"
        puts "actual_url: #{actual_url}"
      end
    end
  end

  task :patronage_refund => :environment do
    require 'csv'
    accounting_reference_number = ENV["REFERENCE_NUMBER"]
    date_approved  = ENV["DATE_APPROVED"]
    CSV.open("#{Rails.root}/tmp/patronage_refund_#{accounting_reference_number}.csv", "w",:write_headers=> true, :headers => ["MEMBER" , "ID_NUMBER" ,"SAVINGS", "CBU" ] ) do |csv|
      account_transaction = AccountTransaction.where("data->>'is_patronage_refund'=? and data->>'is_interest' = ? and status = ?
        and transaction_type = ? and data->>'accounting_entry_reference_number' = ? and transacted_at = ? " , "true","true","approved","deposit","#{accounting_reference_number}","#{date_approved.to_date}")

        account_transaction.each do |at|
          #kimpok
          subsidiary_id = at.subsidiary_id
          savings = at.amount.to_f
          member_account = MemberAccount.find(subsidiary_id)
          member = Member.find(member_account.member_id)
          account_subtype = member_account.account_subtype

          #cbu
          cbu = MemberAccount.where(member_id: member_account.member_id, account_type: "EQUITY", account_subtype: "CBU").first
          cbu_account_transaction = AccountTransaction.where("data->>'is_patronage_refund' = 'true'  and status = 'approved'
          and transaction_type = 'deposit' and transacted_at = '#{date_approved.to_date}' and subsidiary_id = '#{cbu.id}' ").first
          cbu_amount = cbu_account_transaction.amount.to_f
          csv << [member.full_name,member.identification_number,savings,cbu_amount]

        end
    end
  end

  task :admin_adrress_file => :environment do
    start_date  = ENV["START_DATE"] || Date.yesterday
    end_date    = ENV["END_DATE"] || Date.tomorrow

    cmd = ::Exports::SaveAdminAddressCsv.new(
          start_date: start_date,
          end_date: end_date
        )
    cmd.execute!

    file_repository = cmd.file_repository
    actual_url      = file_repository.actual_url
    api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/admin_addresses/process_admin_address_file"
    response = HTTParty.get(api_url, { query: { actual_url: actual_url } })

    if response.code.to_s == "200"
      puts "Successfully called ADMIN ADDRESS API"
    else
      puts "ERROR in calling ADMIN ADDRESS API"
      puts "api_url: #{api_url}"
      puts "actual_url: #{actual_url}"
    end
  end

  task :account_transaction_file_kcoop_to_mba => :environment do
    start_date                = (ENV["START_DATE"] || Date.yesterday).strftime('%Y-%m-%d')
    end_date                  = (ENV["END_DATE"] || Date.tomorrow).strftime('%Y-%m-%d')
    # start_date              = '2024-11-01'
    # end_date                = '2024-11-30'
    is_batch                  = ENV["BATCH"] || true
    end_point                 = ENV['KOINS_RECEIVING_PAYMENTS'] || "http://localhost:3000/api/receive_api/save_account_transaction_from_kcoop"
    account_subtypes          = ["Life Insurance Fund", "Retirement Fund"]
    is_interest               = 'false'
    is_withdraw_payment       = 'false'
    # branches                  = Branch.where(id: "ff757405-81b9-4fba-a3f6-9a7903789295")
    branches                  = Branch.where("cluster_id NOT IN ('ad6de437-60bb-4c0c-bfdb-afb806a35088','4350b839-9774-4b0a-a79b-f71409ad6d2b','168eb8bf-59b4-4401-9498-79c87b3c01d4')")
    date_today                = Date.today.strftime('%Y-%m-%d')
    user_id                   = "2bbf67fc-7982-43bc-a8a6-32d288051fd4"


    # raise [start_date, end_date].inspect
    branches.each do |b|
      account_transactions = AccountTransaction.select(
        "
          members.id as id,
          members.id as member_id,
          branches.name,
          CONCAT(members.last_name, ', ', members.first_name) AS member_name,
          SUM(CASE WHEN member_accounts.account_subtype = 'Life Insurance Fund' THEN account_transactions.amount ELSE 0 END) AS lif_amount,
          SUM(CASE WHEN member_accounts.account_subtype = 'Retirement Fund' THEN account_transactions.amount ELSE 0 END) AS rf_amount
        "
      ).joins(
        "
		      LEFT JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id
          LEFT JOIN members ON members.id = member_accounts.member_id
          LEFT JOIN branches ON branches.id = members.branch_id
        "
      )
      .where(
        "
          (account_transactions.transacted_at >= ? AND account_transactions.transacted_at <= ?)
          AND member_accounts.account_subtype IN (?)
          AND members.branch_id = ?
        ",
        start_date,
        end_date,
        account_subtypes,
        b.id
      ).group(
        "members.id, branches.name"
      )

      Rails.logger.info(puts("Uploading #{account_transactions.size}"))

      account_transaction = {
        branch_id: b.id,
        collection_date: date_today,
        user: user_id,
        api_from: "KCOOP",
        data: account_transactions.each do |o|
          {
            member_id: o.member_id,
            lif_amount: o.lif_amount,
            rf_amount: o.rf_amount
          }
        end
      }

      Rails.logger.info(puts(account_transaction.to_json))

      payload = account_transaction

      if is_batch.present?
        Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
            end_point,
            body: payload.to_json,
            :headers => { 'Content-Type' => 'application/json' },
            timeout: 120
          )
        Rails.logger.info(puts(result))
      else
        payload.each do |p|
          Rails.logger.info(puts "Posting to #{end_point}....")
            result = HTTParty.post(
              end_point,
              body: p.to_json,
              :headers => { 'Content-Type' => 'application/json' },
              timeout: 120
            )
          Rail.logger.info(puts(result))
        end
      end
    end
  end
end
