module MemberAccountValidations
  class CancelMemberAccountValidation
    def initialize(config:)
      @config                       = config

      @member_account_validation    = @config[:member_account_validation]
      @user                         = @config[:user]
      @c_working_date               = ::Utils::GetCurrentDate.new(
                                        config: {
                                          branch: @member_account_validation.branch
                                        }
                                      ).execute!
    end

    def execute!
      @member_account_validation.update!(
        status: "cancelled",
        date_cancelled: @c_working_date,
        cancelled_by: @user.full_name
      )

      @member_account_validation
    end
  end
end
