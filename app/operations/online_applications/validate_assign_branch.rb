module OnlineApplications
  class ValidateAssignBranch < AppValidator
    attr_accessor :errors

    def initialize(online_application:, user:)
      super()

      @online_application = online_application
      @user               = user

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "online_application_assign_branch"
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
