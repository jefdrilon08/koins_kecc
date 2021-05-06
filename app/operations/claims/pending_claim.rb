module Claims
  class PendingClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @user              = @config[:user]
      @branch            = @claim.branch
      @c_working_date    = Date.today

      # @c_working_date    = ::Utils::GetCurrentDate.new(
      #                       config: {
      #                         branch: @branch
      #                       }
      #                     ).execute!
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
