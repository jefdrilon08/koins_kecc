module OnlineApplications
  class Verify
    attr_accessor :online_application,
                  :membership_type,
                  :membership_arrangement,
                  :branch,
                  :user

    def initialize(online_application:, user:, branch: nil, membership_type: nil, membership_arrangement: nil)
      @online_application     = online_application
      @membership_type        = membership_type
      @membership_arrangement = membership_arrangement
      @user                   = user
      @branch                 = branch
    end

    def execute!
      @online_application.data["verified_by"] = {
        id: @user.id,
        name: @user.to_s
      }

      if @branch.present?
        @online_application.branch  = @branch
      end

      @online_application.membership_type         = @membership_type
      @online_application.membership_arrangement  = @membership_arrangement
      @online_application.status                  = "verified"

      @online_application.save!
    end
  end
end
