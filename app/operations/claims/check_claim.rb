module Claims
  class CheckClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @user              = @config[:user]
      @c_working_date    = Date.today
    end

    def execute!
      @claim.update!(
        status: "for-approval",
        date_checked: @c_working_date,
        checked_by: @user.full_name
      )

      @claim
    end
  end
end
