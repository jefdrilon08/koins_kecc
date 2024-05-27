module Claims
  class ValidateHiip

    def initialize(data:, date_prepared:, prepared_by:, claim:)
      @claim                                    = claim
      @data                                     = data
      @date_prepared                            = date_prepared
      @prepared_by                              = prepared_by
      @amount                                   = @data[:amount]
      @certificate_number                       = @data[:certificate_number]
      @date_of_birth                            = @data[:date_of_birth]
      @effective_date_of_coverage               = @data[:effective_date_of_coverage]
      @expiration_date_of_coverage              = @data[:expiration_date_of_coverage]
      @age                                      = @data[:age]
      @date_admitted                            = @data[:date_admitted]
      @date_discharged                          = @data[:date_discharged]
      @number_of_days_tobepaid                  = @data[:number_of_days_tobepaid]
      @reason_of_confinement                    = @data[:reason_of_confinement]
      @diagnosis                                = @data[:diagnosis]
      @name_of_claimant                         = @data[:name_of_claimant]
      @balance                                  = @data[:balance]
      @claims_payment                           = @data[:claims_payment]
      @account_name                             = @data[:account_name]
      @account_number                           = @data[:account_number]
      @errors = []

    end

    def execute!

      if @certificate_number.blank?
        @errors << "Certificate number field is required"
      end

      if @date_of_birth.blank?
        @errors << " Date of birth field is required"
      end

      if @effective_date_of_coverage.blank?
        @errors << "Effective date Number field is required"
      end

      if @expiration_date_of_coverage.blank?
        @errors << "Expiration date field is required"
      end


      if @age.blank?
        @errors << "Age field is required"
      end

      if @amount.blank?
        @errors << "Amount field is required"
      end

      if @date_admitted.blank?
        @errors << "Date admitted is required"
      end

      if @date_discharged.blank?
        @errors << "Date discharged field is required"
      end

      if @number_of_days_tobepaid.blank?
        @errors << "Number of days to be paid field is required"
      end

      if @reason_of_confinement.blank?
        @errors << "Reason of confinement field is required"
      end

      if @diagnosis.blank?
        @errors << "Diagnosis field is required"
      end

      if @name_of_claimant.blank?
        @errors << "Name of claimant field is required"
      end

      if @date_prepared.blank?
        @errors << "Date Prepared field is required"
      end

      # if Date.today.to_date > @expiration_date_of_coverage.to_date
      #   @errors << "Expired HIIP!"
      # end

      # if @number_of_days_tobepaid.to_s >= 15.to_s
      #   @amount = 6000.00
      # end

      if @amount.to_i > 6000.00.to_i
        @errors << "Exceed amount!"
      end

      # if @claims_payment.blank?
      #   @errors << "Claims Payment field is required"
      # end

      # if @account_name.blank?
      #   @errors << "Account name field is required"
      # end

      # if @account_number.blank?
      #   @errors << "Account number field is required"
      # end

      validate_hiip_duplication!
      return  @errors
    end

    private

    def validate_hiip_duplication!
      total_amount = 0.0
      Claim.where("claim_type = ?", "HIIP").each do |hiip|
        hiip_data = hiip.data.with_indifferent_access
        if hiip.member_id == @claim.member_id
          total_amount = total_amount + hiip_data[:amount].to_i
          if total_amount > 6000.00
            @errors << "Exceed amount!"
          end
        end
      end
    end
  end
end
