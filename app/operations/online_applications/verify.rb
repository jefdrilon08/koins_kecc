module OnlineApplications
  class Verify
    attr_accessor :online_application,  
                  :user

    def initialize(online_application:, user:)
      @online_application = online_application
      @user               = user
    end

    def execute!
      @online_application.data["verified_by"] = {
        id: @user.id,
        name: @user.to_s
      }

      @online_application.status = "verified"

      @online_application.save!
    end
  end
end
