module InsuranceLoanBundleEnrollments
  class ValidateDecline < AppValidator

    def initialize(config:)
      super()

      @config        = config
      @insurance_loan_bundle_enrollment         = @config[:insurance_loan_bundle_enrollment]
    end

    def execute!

      if @insurance_loan_bundle_enrollment.blank?
        @errors[:messages] << {
          key: "insurance_loan_bundle_enrollment",
          message: "record not found"
        }
      end

      # if @insurance_loan_bundle_enrollment.approved?
      #   @errors[:messages] << {
      #     key: "insurance_loan_bundle_enrollment",
      #     message: "KDAKILA is already approved!"
      #   }
      # end

      @errors
    end
  end
end
