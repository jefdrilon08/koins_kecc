module MemberAccountValidations
  class ValidateMemberAccountValidation
    def initialize(config:)
      @config                       = config

      @member_account_validation    = @config[:member_account_validation]
      @user                         = @config[:user]
      @c_working_date               = Date.today
    end


    def execute!
      @member_account_validation.update!(
        status: "for-approval",
        date_validated: @c_working_date,
        validated_by: @user.full_name
      )

      # Yung date kung kelan inapproved/validate ng AO ang magiging resignation date
      # @insurance_account_validation.insurance_account_validation_records.each do |iavr|
      #   iavr.update!(
      #     resignation_date: @c_working_date
      #   )
      # end

      @member_account_validation
    end
  end
end
