module Claims
  class PendingClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @user              = @config[:user]
      @c_working_date    = Date.today
    end

    def execute!
      @claim.update!(
        status: "pending",
        date_checked: nil,
        checked_by: nil
      )

      @claim
    end
  end
end
