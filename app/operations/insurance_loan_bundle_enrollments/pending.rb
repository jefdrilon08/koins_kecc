module InsuranceLoanBundleEnrollments
  class Pending
    def initialize(config:)
      @config            = config

      @insurance_loan_bundle_enrollment = @config[:insurance_loan_bundle_enrollment]
      @user                             = @config[:user]
      @branch                           = @insurance_loan_bundle_enrollment.branch
      @data                             = @insurance_loan_bundle_enrollment.data.with_indifferent_access
      @c_working_date                   = Date.today

    end

    def execute!
      @insurance_loan_bundle_enrollment.update!(
        status: "pending",
        data: @data
      )
      @insurance_loan_bundle_enrollment
    end
  end
end
