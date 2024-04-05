module InsuranceLoanBundleEnrollments
  class Check
    def initialize(config:)
      @config                           = config
      @insurance_loan_bundle_enrollment = @config[:insurance_loan_bundle_enrollment]
      @user                             = @config[:user]
      @branch                           = @insurance_loan_bundle_enrollment.branch
      @c_working_date                   = Date.today
      @data                             = @insurance_loan_bundle_enrollment.data.with_indifferent_access
    end


    def execute!
      @insurance_loan_bundle_enrollment.update!(
        status: "for-approval",
        data: @data,
        approved_by: @user.full_name,
      )

      @insurance_loan_bundle_enrollment
    end
  end
end