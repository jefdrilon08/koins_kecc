module OnlineApplications
  class ValidateProcess < AppValidator
    attr_accessor :errors

    def initialize(online_application:, branch:, center:, user:)
      super()

      @online_application = online_application
      @branch             = branch
      @center             = center
      @user               = user
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

      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if @center.blank?
        @errors[:messages] << {
          key: "center",
          message: "center not found"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user required"
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
