module Loaders
  class InsertUsersFromFile
    def initialize(params:)
      @params     = params
      @root       = @params[:root]
      @filename   = @params[:filename]
      @full_path  = "#{@root}/#{@filename}"
      @data       = JSON.parse(File.read(@full_path)).deep_symbolize_keys!
    end

    def execute!
      User.transaction do
        columns = [
          :id, 
          :username, 
          :email, 
          :roles, 
          :first_name, 
          :last_name, 
          :identification_number, 
          :encrypted_password
        ]

        User.import columns, @data[:users], validate: false
      end
    end
  end
end
