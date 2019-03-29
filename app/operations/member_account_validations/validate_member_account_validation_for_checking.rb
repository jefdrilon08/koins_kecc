module MemberAccountValidations
  class ValidateMemberAccountValidationForChecking < AppValidator

    def initialize(config:)
      super()

      @config = config

      @member_account_validation = @config[:member_account_validation]
    end

    def execute!
      if !@member_account_validation.pending? && !@member_account_validation.cancelled?
        @errors[:messages] << {
          key: "member",
          message: "Invalid status"
        }
      end

      @errors
    end
  end
end
