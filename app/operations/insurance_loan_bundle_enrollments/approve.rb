module InsuranceLoanBundleEnrollments
  class Approve
    def initialize(config:)
      @config                                 = config
      @user                                   = @config[:user]
      @insurance_loan_bundle_enrollment       = @config[:insurance_loan_bundle_enrollment]
      @branch                                 = @insurance_loan_bundle_enrollment.branch
      @data                                   = @insurance_loan_bundle_enrollment.data.with_indifferent_access   
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!  
   
      @insurance_loan_bundle_enrollment.update!(
        data: @data,
        approved_by: @user.full_name,
        date_approved: @date_approved
      )
      @insurance_loan_bundle_enrollment
    
    end
  end
  
end