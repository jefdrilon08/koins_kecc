module MemberAccountValidations
  class ValidateMemberAccountValidationForCancellation < AppValidator

    def initialize(config:)
      super ()

      @config                    = config
      @member_account_validation = @config[:member_account_validation]
    end

    def execute!
      if !@member_account_validation.for_approval? && !@member_account_validation.for_validation?
        @errors[:messages] << {
          key: "member",
          message: "Invalid status"
        }
      end

      @errors
    end
  end
end
