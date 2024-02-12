module Members
  class ValidateLogin < Validator
    attr_accessor :user,
                  :token,
                  :errors,
                  :member,
                  :member_logged_before

    def initialize(username:, password:)
      super()
      @username = username
      @password = password

      @errors = {
        username: [],
        password: [],
        mobile_number: []
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
          mobile_number = user.mobile_number.gsub(/[&\/\\#,\-\_()$~%.'":*?<>{}]/, '') # remove all the special characters
          mobile_number = mobile_number.slice(-10..) # slice(-10..) to get the last 10 ex. 9123xxxxxx
          if mobile_number =~ /((\+63)|0|63|)[.\- ]?9[0-9]{2}[.\- ]?[0-9]{3}[.\- ]?[0-9]{4}/

            # check if this member logged in before in koins mobile
            user_data = user.data.with_indifferent_access # get the data first
            if(!user_data.key?(:is_logged_before)) # checking if the is_logged_before is not in the data
              user_data["is_logged_before"] = false # add the is_logged_before with false value

              ####### SEND SMS #########
              gen_six_digit = rand(100_000..999_999) # generate 6 digit code
              user_data["sms_code"] = gen_six_digit.to_s # add the sms_code with the generated code

              user.update(data: user_data) # then update

            else
              if(user_data["is_logged_before"]) # this member logged in before in koins mobile
                @token  = user.generate_jwt # create the token

              else # if this member is not logged in yet
                ####### SEND SMS ######### (AGAIN)
                gen_six_digit = rand(100_000..999_999) # generate 6 digit code
                user_data["sms_code"] = gen_six_digit.to_s # add the sms_code with the generated code

                user.update(data: user_data) # then update

              end
            end

            @member = user
            @member_logged_before = user_data["is_logged_before"]
            
          else
            @errors[:mobile_number] << 'invalid mobile number'
          end          
        end
      end

      count_errors!
    end
  end
end
