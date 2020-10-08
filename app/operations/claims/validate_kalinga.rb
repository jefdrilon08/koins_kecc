module Claims
  class ValidateKalinga

    # def initialize(data:, gender:, date_prepared:, policy_number:, type_of_insurance_policy:, name_of_insured:, beneficiary:, classification_of_insured:, date_of_birth:, date_of_policy_issue:, face_amount:, date_of_death_tpd_accident:, arrears:, cause_of_death_tpd_accident:, equity_value:, retirement_fund:, prepared_by:, length_of_stay:, returned_contribution:, total_amount_payable:, order_of_child:, category_of_cause_of_death_tpd_accident:, date_reported:, date_paid:, age: )
      def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                                    = claim
        @data                                     = data
        @date_prepared                            = date_prepared
        @prepared_by                              = prepared_by
        @amount                                   = @data[:amount]
        @date_approved                            = @data[:date_approved]
        @effective_date                           = @data[:effective_date]
        @expiration_date                          = @data[:expiration_date]
        @poc_number                               = @data[:poc_number]
        @name_of_insured                          = @data[:name_of_insured]
        @relationship_to_member                   = @data[:relationship_to_member]
        @insured_address                          = @data[:insured_address]
        @civil_status                             = @data[:civil_status]
        @date_of_birth                            = @data[:date_of_birth]
        @name_of_beneficiary                      = @data[:name_of_beneficiary]
        @date_of_death_or_incident                = @data[:date_of_death_or_incident]
        @reason_of_death                          = @data[:reason_of_death]
        @gender                                   = @data[:gender]
        @claims_payment                           = @data[:claims_payment]
        @account_name                             = @data[:account_name]
        @account_number                           = @data[:account_number]


        @errors = []

    end

    def execute!
      if @date_approved.blank?
        @errors << " Date Approved field is required"
      end

      if @amount.blank?
        @errors << "Amount field is required"
      end

      if @effective_date.blank?
        @errors << "Effective date field is required"
      end

      if @expiration_date.blank?
        @errors << "Expiration date of Insured field is required"
      end

      if @poc_number.blank?
        @errors << "POC # field is required"
      end

      if @name_of_insured.blank?
        @errors << "Name of insured field is required"
      end

      if @relationship_to_member.blank?
        @errors << "Classification field is required"
      end

      if @insured_address.blank?
        @errors << "Insured address field is required"
      end

      if @civil_status.blank?
        @errors << "Civil Status field is required"
      end

      if @date_of_birth.blank?
        @errors << "Date of Birth field is required"
      end

      if @name_of_beneficiary.blank?
        @errors << "Name of beneficiary field is required"
      end

      if @date_of_death_or_incident.blank?
        @errors << "Date of Death or incident field is required"
      end

      if @reason_of_death.blank?
        @errors << "Reason of death field is required"
      end

      if @gender.blank?
        @errors << "Gender field is required"
      end

      if Date.today.to_date > @expiration_date.to_date
        @errors << "Expired KALINGA!"
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

      #validate_kalinga_duplication!
      return  @errors
    end

    def validate_kalinga_duplication!
      count = Claim.where("member_id = ? AND claim_type = ? AND date_prepared = ? AND 
        data->>'amount' = ? AND data->>'date_approved' = ? AND data->>'effective_date' = ? AND 
        data->>'expiration_date' = ? AND data->>'poc_number' = ? AND data->>'name_of_insured' = ? AND 
        data->>'relationship_to_member' = ? AND data->>'insured_address' = ? AND data->>'civil_status' = ? AND 
        data->>'date_of_birth' = ? AND data->>'name_of_beneficiary' = ? AND 
        data->>'date_of_death_or_incident' = ? AND data->>'reason_of_death' = ? AND data->>'gender' = ? AND
        data ->> 'claims_payment' = ? AND data ->> 'account_name' = ? AND data ->> 'account_number' = ?", 
        @claim.member_id, "K-KALINGA", @date_prepared, @amount, @date_approved, @effective_date, 
        @expiration_date, @poc_number, @name_of_insured, @relationship_to_member, @insured_address, 
        @civil_status, @date_of_birth, @name_of_beneficiary, @date_of_death_or_incident, @reason_of_death, 
        @gender, @claims_payment, @account_name, @account_number).count
        if count > 0
          @errors << "Duplicate KALINGA!"
        end

    end
  end
end