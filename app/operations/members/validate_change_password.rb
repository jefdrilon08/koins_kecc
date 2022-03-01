module Members
  class ValidateChangePassword
    attr_accessor :member, :errors

    def initialize(member:, old_password:, password:, password_confirmation:)
      @member                 = member
      @old_password           = old_password
      @password               = password
      @password_confirmation  = password_confirmation

      @errors = []
    end

    def execute!
      if @member.blank?
        @errors << {
          member: "Member not found"
        }
      end

      if @old_password.blank?
        @errors << {
          old_password: "Old password required"
        }
      end

      if @old_password.present? and @member.present?
        user = Member.find_by_username(@member.username)

        if user.blank?
          @errors << {
            member: "Member not found"
          }
        elsif !user.valid_password?(@old_password)
          @errors << {
            old_password: "Password incorrect"
          }
        end
      end

      if @password.blank?
        @errors << {
          password: "New password required"
        }
      end

      if @password_confirmation.blank?
        @errors << {
          password_confirmation: "Password confirmation required"
        }
      end

      if @password.present? and @password_confirmation.present?
        @errors << {
          password: "Passwords are not the same"
        }

        @errors << {
          password_confirmation: "Passwords are not the same"
        }
      end
    end
  end
end
