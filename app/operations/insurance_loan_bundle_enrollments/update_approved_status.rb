module InsuranceLoanBundleEnrollments
  class UpdateApprovedStatus
    def initialize(config:)
      config = config
      @insurance_loan_bundle_enrollment = config[:insurance_loan_bundle_enrollment]
      @kok =  @insurance_loan_bundle_enrollment[:id]

      # raise @kok.inspect
    end

    def execute!
      InsuranceLoanBundleEnrollment.find("#{@kok}").update!(status: "approved")
    end
  end
end
