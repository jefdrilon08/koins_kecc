module Claims
  class ApproveClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @user              = @config[:user]
      @c_working_date    = Date.today
    end

    def execute!
      @claim.update!(
        status: "for-posting",
        date_approved: @c_working_date,
        approved_by: @user.full_name
      )

      @claim
    end
  end
end
