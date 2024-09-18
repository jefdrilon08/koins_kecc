module InsuranceLoanBundleEnrollments
  class UpdateBeneficiary
    def initialize(config:)
      @config                                       = config
      @insurance_loan_bundle_enrollment             = @config[:insurance_loan_bundle_enrollment]
      @benif_fname                                  = @config[:benif_fname]
      @benif_mname                                  = @config[:benif_mname]
      @benif_lname                                  = @config[:benif_lname]
      @benif_birth_date                             = @config[:benif_birth_date]
      @benif_gender                                 = @config[:benif_gender]
      @benif_relationship                           = @config[:benif_relationship]
      @data                                         = @insurance_loan_bundle_enrollment.data.with_indifferent_access
    end

    def execute!
      # Get the last record in the :records array
      last_record = @data[:records].last

      # Update the necessary fields in the last record
      last_record[:kok_data][:benif_fname] = @benif_fname
      last_record[:kok_data][:benif_mname] = @benif_mname
      last_record[:kok_data][:benif_lname] = @benif_lname
      last_record[:kok_data][:benif_birth_date] = @benif_birth_date
      last_record[:kok_data][:benif_gender] = @benif_gender
      last_record[:kok_data][:benif_relationship] = @benif_relationship

      # Update the @insurance_loan_bundle_enrollment with the modified data
      @insurance_loan_bundle_enrollment.update!(data: @data)

      # Return the updated enrollment
      @insurance_loan_bundle_enrollment
    end
  end
end
