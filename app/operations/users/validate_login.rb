module Users
  class ValidateLogin
    attr_accessor :user,
                  :token,
                  :errors

    def initialize(username:, password:)
      @username = username
      @password = password

      @errors = {}
    end

    def execute!
      if @username.blank?
        @errors['username'] = 'Username required'
      end

      if @password.blank?
        @errors['password'] = 'Password required'
      end

      if @username.present? and @password.present?
        @user = User.find_by_username(@username)

        if user.blank?
          @errors['username'] = 'User not found'
        elsif !user.valid_password?(@password)
          @errors['password'] = 'Invalid password'
        elsif !user.verified?
          @errors['username'] = 'User is not verified'
        else
          @token = user.generate_jwt
        end
      end
    end
  end
end
