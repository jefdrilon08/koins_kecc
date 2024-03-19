module InsuranceLoanBundleEnrollments
  class ValidateLoanBundleEnrollmentsFromCsvFile < AppValidator
    def initialize(insurance_loan_bundle_enrollments:, config:)
      super()
      @config                                 = config
      @insurance_loan_bundle_enrollments      = insurance_loan_bundle_enrollments
      @branch_id                              = @insurance_loan_bundle_enrollments['branch_id']
      @member_fname                           = @insurance_loan_bundle_enrollments['fname']
      @member_lname                           = @insurance_loan_bundle_enrollments['lname']        
    end

    def execute!
      check_center_is_valid!
      @errors
    end

    private

    def check_center_is_valid!
      branch = Branch.where(id: @branch_id).first
      if @branch_id.nil?
        @errors[:messages] << {
          key: "branch",
          message: "branch is empty #{@branch_id} "
        }
      elsif branch.nil?
        @errors[:messages] << {
          key: "branch",
          message: "branch is not valid: #{@branch_id} "
        }
      end
    end


  end
end