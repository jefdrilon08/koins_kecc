module Members
  class ValidateLogin < Validator
    attr_accessor :user,
                  :token,
                  :errors,
                  :member,
                  :is_otp_verified,
                  :is_password_changed

    def initialize(username:, password:)
      super()
      @username = username
      @password = password

      @newMemberDate =  Date.parse("Feb 15, 2024").strftime("%Y-%m-%d")
      # this date to check if the member is new and old
      # this date is only for testing.
      # change this date when deploying

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
          user_data = user.data.with_indifferent_access # get the data first
          # Check if the member is new or old
          if (user.date_of_membership.present? and Date.parse(user.date_of_membership).strftime("%Y-%m-%d") >= @newMemberDate) # this is new member
            
            if(user_data.key?(:is_otp_verified)) 
              if(user_data["is_otp_verified"]) # this member done in otp 
                if(user_data.key?(:is_password_changed)) 
                  if(user_data["is_password_changed"]) # this member can now login direct to dashboard
                    @token  = user.generate_jwt # create the token
                  end
                  
                else # this member need to change password
                  user_data["is_password_changed"] = false
                end

              end

            else
              user_data["is_otp_verified"] = false
            end

            # # send sms temporary only (for testing only)
            # gen_six_digit = rand(100_000..999_999) # generate 6 digit code
            # user_data["sms_code"] = gen_six_digit.to_s # add the sms_code with the generated code
            
            user.update(data: user_data) # update member's data

          else # this member is old, this member can login direct to dashboard
            user_data["is_otp_verified"] = true # this member not required to input otp
            if(user_data.key?(:is_password_changed)) 
              if(user_data["is_password_changed"]) # this member can now login direct to dashboard
                @token  = user.generate_jwt # create the token
              end
              
            else # this member need to change password
              user_data["is_password_changed"] = false
            end

            user.update(data: user_data) # update member's data
          end          

          @member = user
          @is_otp_verified = user_data["is_otp_verified"]
          @is_password_changed = user_data["is_password_changed"]
        
        end
      end

      count_errors!
    end
  end
end
