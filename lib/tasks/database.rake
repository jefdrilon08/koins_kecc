namespace :db do
  desc "Restore database"
  task :restore => :environment do
    puts "Restoring database..."

    if ::ActiveRecord::Base.connection_config[:adapter] == 'postgresql'
      cmd = nil
      with_config do |app, host, db, user, pw|
        cmd = "PGPASSWORD=#{pw} pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{ENV['PG_BACKUP_DUMP']}"
      end
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      puts cmd
      exec cmd
    else
      puts "Invalid database adapter"
    end
  end

  task :save_accounting_codes => :environment do
    accounting_codes  = AccountingCode.all
    filename          = "accounting-codes-v2.json"
    full_path         = "#{Rails.root}/db_backup/#{filename}"

    data = { 
      accounting_codes: []
    }   

    accounting_codes.each do |o| 
      data[:accounting_codes] << o.to_version_2_hash
    end 

    puts "Saving file to #{full_path}..."

    File.write(full_path, JSON.pretty_generate(data))

    puts "Done!"
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end
end
