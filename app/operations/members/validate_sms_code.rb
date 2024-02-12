module Members
    class ValidateSmsCode < Validator
        attr_accessor :user,
                        :token,
                        :errors,
                        :member

        def initialize(username:, password:, code:)
            super()
            @username = username
            @password = password
            @code = code
    
            @errors = {
                username: [],
                password: [],
                code: []
            }
        end
      
        def execute!
            if @username.blank?
                @errors[:username] << 'username required'
            end

            if @password.blank?
                @errors[:password] << 'password required'
            end

            if @code.blank?
                @errors[:code] << 'code required'
            end

            if @username.present? and @password.present?
                user = Member.find_by_username(@username)

                if user.blank?
                    @errors[:username] << 'user not found'
                elsif not user.valid_password?(@password)
                    @errors[:password] << 'invalid password'
                elsif not user.active?
                    @errors[:username] << 'invalid status'
                elsif user.data["sms_code"] == @code # if the sms code is match
                    @token  = user.generate_jwt # create the token

                    user_data = user.data.with_indifferent_access # get the data first
                    user_data["is_logged_before"] = true # change to true
                    user_data.delete(:sms_code) # delete the sms code
                    user.update(data: user_data) # then update

                    @member = Member.find_by_username(@username) # to the the updated data of member
                    
                else
                    @errors[:code] << 'invalid code'
                end
            end
            count_errors!
        end
    end
end

