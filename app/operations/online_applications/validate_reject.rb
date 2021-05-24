module OnlineApplications
  class ValidateReject < AppValidator
    attr_accessor :errors

    def initialize(online_application:, user:, reason:)
      super()

      @online_application = online_application
      @user               = user
      @reason             = reason
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
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user required"
        }
      elsif @user.current_roles.intersection(Settings.try(:module_authorization_roles).try(:mykoins) || []).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized to perform action"
        }
      end

      if @reason.blank?
        @errors[:messages] << {
          key: "reason",
          message: "reason required"
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
