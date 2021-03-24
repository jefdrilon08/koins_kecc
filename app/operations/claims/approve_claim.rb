module Claims
  class ApproveClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @user              = @config[:user]
      @branch            = @claim.branch
      @c_working_date    = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch
                            }
                          ).execute!
    end

    def execute!
      @claim.update!(
        status: "for-posting",
        date_approved: @c_working_date,
        approved_by: @user.print_full_name.titleize
      )

      @claim
    end
  end
end
