module MemberAccountValidations
  class CancelMemberToMemberAccountValidation
    def initialize(config:)
      @config                         = config

      @reason                         = @config[:reason]
      @member                         = @config[:member]
      @member_account_validation      = @config[:member_account_validation]
      @date_cancelled                 = @config[:date_cancelled]
      @user                           = @config[:user]
      @c_working_date                 = Date.today
    end

    def execute!
      create_member_account_validation_cancellation!

      @member_account_validation_cancellation.save!
    end

    def create_member_account_validation_cancellation!
      @member_account_validation_cancellation = MemberAccountValidationCancellation.new(
        member_id: @member.id,
        branch_id: @member_account_validation.branch.id,
        member_account_validation_id: @member_account_validation.id,
        date_cancelled: @date_cancelled,
        reason: @reason
        )

      @member_account_validation_cancellation
    end
  end
end
