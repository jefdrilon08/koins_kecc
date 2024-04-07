module InsuranceLoanBundleEnrollments
  class ValidateCheck < AppValidator
    def initialize(config:)
      super()

      @config                            = config
      @insurance_loan_bundle_enrollment  = @config[:insurance_loan_bundle_enrollment]
    end

    def execute!
      if @insurance_loan_bundle_enrollment.blank?
        @errors[:messages] << {
          key: "insurance_loan_bundle_enrollment",
          message: "record not found"
        }
      end

      if !@insurance_loan_bundle_enrollment.pending?
        @errors[:messages] << {
          key: "insurance_loan_bundle_enrollment",
          message: "Invalid status"
        }
      end
     
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end





