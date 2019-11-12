module Utils
  class BackupDatabase
    def initialize(config:)
      @config = config

      @pw       = ::ActiveRecord::Base.connection_config[:password]
      @host     = ::ActiveRecord::Base.connection_config[:host]
      @username = ::ActiveRecord::Base.connection_config[:username]
      @db       = ::ActiveRecord::Base.connection_config[:database]

      @destination_file = @config[:destination_file]
    end

    def execute!
      cmd = "PGPASSWORD=#{@pw} pg_dump --host #{@host} --username #{@username} --verbose --clean --no-owner --no-acl --format=c #{@db} > #{@destination_file}"
      `#{cmd}`
    end
  end
end
