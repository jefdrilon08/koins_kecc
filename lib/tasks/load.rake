namespace :load do
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
