module MemberAccountValidations
  class ValidateMemberAccountValidationForValidation < AppValidator

    def initialize(config:)
      super()

      @config = config

      @member_account_validation = @config[:member_account_validation]
    end

    def execute!
      # if !@insurance_account_validation.for_validation?
      #   @errors << "Invalid status"
      # end

      @errors
    end
  end
end
