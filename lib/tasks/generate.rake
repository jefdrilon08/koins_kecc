namespace :generate do
  task :cutoff_reports => :environment do
    ProcessCutoffReports.perform_later({})
  end

  task :members_file => :environment do
    start_date  = ENV["START_DATE"] || Date.today
    end_date    = ENV["END_DATE"] || Date.today

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
    start_date  = ENV["START_DATE"] || Date.today
    end_date    = ENV["END_DATE"] || Date.today

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
    start_date  = ENV["START_DATE"] || Date.today
    end_date    = ENV["END_DATE"] || Date.today

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
    start_date  = ENV["START_DATE"] || Date.today
    end_date    = ENV["END_DATE"] || Date.today

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

  task :insurance_account_transactions_file => :environment do
    start_date  = ENV["START_DATE"] || Date.today
    end_date    = ENV["END_DATE"] || Date.today

    cmd = ::Exports::SaveAccountTransactionsCsv.new(
            start_date: start_date,
            end_date: end_date
          )

    if cmd.account_transactions.any?
      cmd.execute!

      file_repository = cmd.file_repository
      actual_url      = file_repository.actual_url

      api_url = "#{ENV['INSURANCE_KOINS_URL']}/api/v1/insurance_accounts/process_insurance_account_transactions_file"

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
end
