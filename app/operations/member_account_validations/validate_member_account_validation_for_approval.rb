module MemberAccountValidations
  class ValidateMemberAccountValidationForApproval < AppValidator
    def initialize(config:)
     super()

      @config = config
      @member_account_validation = @config[:member_account_validation]
      @branch = @member_account_validation.branch
    end

    def execute!
      check_params!
      @errors
    end

    private

    def check_params!
      if @branch.nil?
        @errors[:messages] << {
          key: "member",
          message: "Branch cant be blank."
        }
      end

      if @member_account_validation.date_prepared.nil?
        @errors[:messages] << {
          key: "member",
          message: "Date Prepared cant be blank."
        }  
      end
    end
  end
end
