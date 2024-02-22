module InsuranceLoanBundleEnrollments
  class Save
    def initialize(config:)
      @config             = config
      @branch             = @config[:branch]
      @center             = @config[:center]
      @collection_date    = @config[:collection_date]
      @user               = @config[:user]

      @insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollment.new(
                                                  branch: @branch,
                                                  center: @center,
                                                  collection_date: @collection_date,
                                                  data: {
                                                    records: []
                                                  }
                                                )
    end

    def execute!
      @insurance_loan_bundle_enrollment.save!
      @insurance_loan_bundle_enrollment
    end
  end
end