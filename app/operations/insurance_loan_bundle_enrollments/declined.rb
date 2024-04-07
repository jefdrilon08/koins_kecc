module InsuranceLoanBundleEnrollments
  class Declined
    def initialize(config:)

      @config = config
      @insurance_loan_bundle_enrollment = @config[:insurance_loan_bundle_enrollment]
      @data = @insurance_loan_bundle_enrollment.data.with_indifferent_access
    end

    def execute!
      @insurance_loan_bundle_enrollment.update!(
        status: "declined",
        data: @data,
      )

      @insurance_loan_bundle_enrollment
    end
  end
end
