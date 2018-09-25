module Loaders
  class InsertUsersFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
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
