module OnlineApplications
  class Verify
    attr_accessor :online_application,  
                  :branch,
                  :user

    def initialize(online_application:, user:, branch: nil)
      @online_application = online_application
      @user               = user
      @branch             = branch
    end

    def execute!
      @online_application.data["verified_by"] = {
        id: @user.id,
        name: @user.to_s
      }

      if @branch.present?
        @online_application.branch  = @branch
      end

      @online_application.status  = "verified"

      @online_application.save!
    end
  end
end
