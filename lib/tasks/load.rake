namespace :load do
  task :loan_payments_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoanPaymentsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :member_account_transactions_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMemberAccountTransactionsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :member_accounts_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMemberAccountsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :amortization_schedule_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAmortizationScheduleEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :loans_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoansFromFile.new(params: params).execute!

    puts "Done."
  end

  task :loan_products_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoanProductsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :project_types_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertProjectTypesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :project_type_categories_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertProjectTypeCategoriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :journal_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertJournalEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :accounting_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountingEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :members_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMembersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :centers_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertCentersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :branches_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertBranchesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :clusters_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertClustersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :areas_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAreasFromFile.new(params: params).execute!

    puts "Done."
  end

  task :accounting_codes_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountingCodesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :users_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertUsersFromFile.new(params: params).execute!

    puts "Done."
  end
end
