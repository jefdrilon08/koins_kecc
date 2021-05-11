module OnlineApplications
  class Reject
    attr_accessor :online_application,  
                  :user,
                  :reason

    def initialize(online_application:, user:, reason:)
      @online_application = online_application
      @user               = user
      @reason             = reason
    end

    def execute!
      @online_application.data["reason_for_rejection"]  = @reason

      @online_application.data["rejected_by"] = {
        id: @user.id,
        name: @user.to_s
      }

      @online_application.status = "rejected"

      @online_application.save!
    end
  end
end
