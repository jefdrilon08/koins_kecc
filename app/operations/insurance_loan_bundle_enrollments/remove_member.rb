module InsuranceLoanBundleEnrollments
  class RemoveMember
    def initialize(config:)
      @config                                 = config
      @insurance_loan_bundle_enrollment       = @config[:insurance_loan_bundle_enrollment]
      @member                                 = @config[:member]
      @member_index                           = @config[:member_index]
      @user                                   = @config[:user]
      @branch                                 = @insurance_loan_bundle_enrollment.branch
      @data                                   = @insurance_loan_bundle_enrollment.try(:data).try(:with_indifferent_access)

    end

    def execute!
      @data[:records].each_with_index do |o, index|
        if @member_index.to_i == index
          @data[:records].delete_at(index)
        end
      end

      @insurance_loan_bundle_enrollment.update!(data: @data)
      @insurance_loan_bundle_enrollment
    end
  end
end