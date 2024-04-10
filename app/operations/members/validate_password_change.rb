module Members
    class ValidatePasswordChange < AppValidator
      attr_accessor :member,
                    :password_changed,
                    :errors
  
      def initialize(member:, password:, password_confirmation:)
        super()
  
        @member                 = member
        @password               = password
        @password_confirmation  = password_confirmation
      end
  
      def execute!
        if @member.blank?
          @errors[:messages] << {
            key: "member",
            message: "member not found"
          }
        end
  
        if @password.blank?
          @errors[:messages] << {
            key: "password",
            message: "password not found"
          }
        end
  
        if @password_confirmation.blank?
          @errors[:messages] << {
            key: "password_confirmation",
            message: "password confirmation not found"
          }
        end
  
        if @password.present? and @password_confirmation.present? and @password != @password_confirmation
          @errors[:messages] << {
            key: "password",
            message: "password values not equal"
          }
        end
  
        build_full_messages!
      end
    end
  end
  