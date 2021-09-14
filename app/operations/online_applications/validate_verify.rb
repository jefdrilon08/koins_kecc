module OnlineApplications
  class ValidateVerify < AppValidator
    attr_accessor :errors

    def initialize(online_application:, user:, membership_type: nil, membership_arrangement: nil)
      super()

      @online_application     = online_application
      @membership_type        = membership_type
      @membership_arrangement = membership_arrangement
      @user                   = user

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "online_application_verify"
                      ).execute!
    end

    def execute!
      if @online_application.blank?
        @errors[:messages] << {
          key: "online_application",
          message: "online application not found"
        }
      elsif @online_application.processed?
        @errors[:messages] << {
          key: "online_application",
          message: "online application is already processed"
        }
      elsif !@online_application.for_verification?
        @errors[:messages] << {
          key: "online_application",
          message: "invalid status"
        }
      end

      if @online_application.present?
        if @membership_type.blank?
          @errors[:messages] << {
            key: "online_application",
            message: "membership_type required"
          }
        end

        if @membership_arrangement.blank?
          @errors[:messages] << {
            key: "online_application",
            message: "membership_arrangement required"
          }
        end
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user required"
        }
      elsif @user.current_roles.intersection(@valid_roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized to perform action"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
