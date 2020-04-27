module Claims
  class ValidateKbente

    # def initialize(data:, gender:, date_prepared:, policy_number:, type_of_insurance_policy:, name_of_insured:, beneficiary:, classification_of_insured:, date_of_birth:, date_of_policy_issue:, face_amount:, date_of_death_tpd_accident:, arrears:, cause_of_death_tpd_accident:, equity_value:, retirement_fund:, prepared_by:, length_of_stay:, returned_contribution:, total_amount_payable:, order_of_child:, category_of_cause_of_death_tpd_accident:, date_reported:, date_paid:, age: )
      def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                                    = claim
        @data                                     = data
        @date_prepared                            = date_prepared
        @prepared_by                              = prepared_by
        @amount                                   = @data[:amount]
        @date_approved                            = @data[:date_approved]
        @date_of_birth                            = @data[:date_of_birth]
        @purpose                                  = @data[:purpose]
        @name_of_insured                          = @data[:name_of_insured]
        @name_of_beneficiary                      = @data[:name_of_beneficiary]
        @classification                           = @data[:classification]
        @date_of_death                            = @data[:date_of_death]
        @date_enrolled                            = @data[:date_enrolled]
        @date_expired                             = @data[:date_expired]

        @errors = []

    end

    def execute!

      if @date_approved.blank?
        @errors << " Date Approved field is required"
      end

      if @date_of_birth.blank?
        @errors << "Date of Birth field is required"
      end

      if @purpose.blank?
        @errors << "Purpose field is required"
      end

      if @amount.blank?
        @errors << "Amount field is required"
      end


      if @name_of_insured.blank?
        @errors << "Name of insured field is required"
      end

      if @name_of_beneficiary.blank?
        @errors << "Name of beneficiary field is required"
      end

      if @classification.blank?
        @errors << "Classification field is required"
      end

      if @date_of_death.blank?
        @errors << "Date of Death field is required"
      end

      if @date_enrolled.blank?
        @errors << "Date enrolled field is required"
      end

      if @date_expired.blank?
        @errors << "Date expired field is required"
      end

      if Date.today.to_date > @date_expired.to_date
        @errors << "Expired K-BENTE!"
      end

      validate_kbente_duplication!
      return  @errors
    end

    private

    def validate_kbente_duplication!
      count = Claim.where("member_id = ? AND claim_type = ? AND data->>'purpose' = ? AND data->>'date_of_death' = ?",@claim.member_id, "K-BENTE", @purpose, @date_of_death).count
        if count > 0
          @errors << "Duplicate K-BENTE!"
        end
       
    end
  end
end
