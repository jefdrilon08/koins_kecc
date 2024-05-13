module InsuranceLoanBundleEnrollments
  class UpdateOverAgeStatus
    def initialize(config:)
      config = config
      @insurance_loan_bundle_enrollment = config[:insurance_loan_bundle_enrollment]
      @kok =  @insurance_loan_bundle_enrollment[:id]

      # raise @kok.inspect
    end

    def execute!
      InsuranceLoanBundleEnrollment.find("#{@kok}").update!(status: "over-age")
    end
  end
end
