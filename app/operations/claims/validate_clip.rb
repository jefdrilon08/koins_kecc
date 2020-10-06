module Claims
  class ValidateClip

    def initialize(data:, date_prepared:, prepared_by:, claim:)
      @claim                                    = claim
      @data                                     = data
      @date_prepared                            = date_prepared
      @prepared_by                              = prepared_by
      @amount                                   = @data[:amount]
      @gender                                   = @data[:gender]
      @policy_number                            = @data[:policy_number]
      @creditors_name                           = @data[:creditors_name]
      @member_name                              = @data[:member_name]
      @beneficiary                              = @data[:beneficiary]
      @date_of_death                            = @data[:date_of_death]  
      @date_of_birth                            = @data[:date_of_birth]
      @cause_of_death                           = @data[:cause_of_death]
      @effective_date_of_coverage               = @data[:effective_date_of_coverage]
      @expiration_date_of_coverage              = @data[:expiration_date_of_coverage]
      @age                                      = @data[:age]
      @terms                                    = @data[:terms]
      @amount_of_loan                           = @data[:amount_of_loan]
      @amount_payable_to_creditor               = @data[:amount_payable_to_creditor]
      @type_of_loan                             = @data[:type_of_loan]
      @claims_payment                           = @data[:claims_payment]
      @account_name                             = @data[:account_name]
      @account_number                           = @data[:account_number]
      
      @errors = []

    end

    def execute!
      # validate_claim_duplication!
      if @gender.blank?
        @errors << "Gender field is required"
      end

      if @date_prepared.blank?
        @errors << " Date Prepared field is required"
      end

      if @policy_number.blank?
        @errors << "Policy Number field is required"
      end

      if @creditors_name.blank?
        @errors << "Creditors Name field is required"
      end

      if @member_name.blank?
        @errors << "Member name field is required"
      end

      if @beneficiary.blank?
        @errors << "Beneficiary field is required"
      end

      if @date_of_death.blank?
        @errors << "Date of Death field is required"
      end

      if @date_of_birth.blank?
        @errors << "Date of Birth field is required"
      end

      if @cause_of_death.blank?
        @errors << "Cause of Death field is required"
      end

      if @effective_date_of_coverage.blank?
        @errors << "Effective date of Coverage field is required"
      end

      if @expiration_date_of_coverage.blank?
        @errors << "Expiration Date of Coverage field is required"
      end

      if @amount_of_loan.blank?
        @errors << "Amount of Loan field is required"
      end

      if @terms.blank?
        @errors << "Terms field is required"
      end

      if @amount_payable_to_creditor.blank?
        @errors << "Amount Payable to Creditor field is required"
      end

      if @amount.blank?
        @errors << "Amount Payable to Beneficiary field is required"
      end

      if @prepared_by.blank?
        @errors << "Prepared By field is required"
      end

      if @type_of_loan.blank?
        @errors << "Type of Loan field is required"
      end

      if @age.blank?
        @errors << "Age field is required"
      end

      if @claims_payment.blank?
        @errors << "Claims Payment field is required"
      end

      if @account_name.blank?
        @errors << "Account name field is required"
      end

      if @account_number.blank?
        @errors << "Account number field is required"
      end

      #validate_clip_duplication!
      return  @errors
    end

    private

    def validate_clip_duplication!
      count = Claim.where("member_id = ? AND claim_type = ? AND date_prepared = ? AND 
        data->>'amount' = ? AND data->>'gender' = ? AND data->>'policy_number' = ? AND 
        data->>'creditors_name' = ? AND data->>'member_name' = ? AND data->>'beneficiary' = ? AND 
        data->>'date_of_death' = ? AND data->>'date_of_birth' = ? AND data->>'cause_of_death' = ? AND 
        data->>'effective_date_of_coverage' = ? AND data->>'expiration_date_of_coverage' = ? AND 
        data->>'age' = ? AND data->>'terms' = ? AND data->>'amount_of_loan' = ? AND data->>'amount_payable_to_creditor' = ? AND 
        data->>'type_of_loan' = ? AND 
        data ->> 'claims_payment' = ? AND data ->> 'account_name' = ? AND data ->> 'account_number' = ?", 
        @claim.member_id, "CLIP", @date_prepared, @amount, @gender, @policy_number, 
        @creditors_name, @member_name, @beneficiary, @date_of_death, @date_of_birth, 
        @cause_of_death, @effective_date_of_coverage, @expiration_date_of_coverage, @age, @terms, 
        @amount_of_loan, @amount_payable_to_creditor, @type_of_loan, @claims_payment, @account_name, @account_number).count
        if count > 0
          @errors << "Duplicate CLIP!"
        end
    end
  end
end

