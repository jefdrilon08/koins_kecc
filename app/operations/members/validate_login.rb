module Members
  class ValidateLogin < Validator
    attr_accessor :user,
                  :token,
                  :errors,
                  :member

    def initialize(username:, password:)
      super()
      @username = username
      @password = password

      @errors = {
        username: [],
        password: []
      }
    end

    def execute!
      if @username.blank?
        @errors[:username] << 'username required'
      end

      if @password.blank?
        @errors[:password] << 'password required'
      end

      if @username.present? and @password.present?
        user = Member.find_by_username(@username)

        if user.blank?
          @errors[:username] << 'user not found'
        elsif not user.valid_password?(@password)
          @errors[:password] << 'invalid password'
        elsif not user.active?
          @errors[:username] << 'invalid status'
        else
          @token  = user.generate_jwt
          @member = user
        end
      end

      count_errors!
    end
  end
end
