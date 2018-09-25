namespace :load do
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
