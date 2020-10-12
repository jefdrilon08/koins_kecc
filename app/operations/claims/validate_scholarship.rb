module Claims
  class ValidateScholarship

    def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                    = claim
        @data                     = data
        @date_prepared            = date_prepared
        @prepared_by              = prepared_by
        @amount                   = @data[:amount]
        @name_of_beneficiary      = @data[:name_of_beneficiary]
        @payee                    = @data[:payee]
        @name_of_school           = @data[:name_of_school]
        @school_year              = @data[:school_year]
        @year_level               = @data[:year_level]
        @sem                      = @data[:sem]
        @scholarship_type         = @data[:scholarship_type]
        @final_grade              = @data[:final_grade]
        @classification           = @data[:classification]
        @course                   = @data[:course]
        @claims_payment           = @data[:claims_payment]
        @account_name             = @data[:account_name]
        @account_number           = @data[:account_number]

        @errors = []

    end

    def execute!
      #validate_claim_duplication!
      if @name_of_beneficiary.blank?
        @errors << "Date reported field is empty"
      end
      if @payee.blank?
        @errors << "Date Emailed field is required"
      end

      if @amount.blank?
        @errors << " Date Approved field is required"
      end

      if @name_of_school.blank?
        @errors << "Date Requested field is required"
      end

      if @school_year.blank?
        @errors << "Purpose field is required"
      end

      if @year_level.blank?
        @errors << "Amount field is required"
      end

      if @scholarship_type.blank?
        @errors << "Expiration date of Insured field is required"
      end

      if @final_grade.blank?
        @errors << "POC # field is required"
      end

      if @classification.blank?
        @errors << "Classification field is required"
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

      #validate_scholar_duplication!
      return  @errors
    end

   private

    def validate_scholar_duplication!
      count = Claim.where("member_id = ? AND claim_type = ? AND date_prepared = ? AND 
        data->>'amount' = ? AND data->>'name_of_beneficiary' = ? AND data->>'payee' = ? AND 
        data->>'name_of_school' = ? AND data->>'school_year' = ? AND data->>'year_level' = ? AND 
        data->>'sem' = ? AND data->>'scholarship_type' = ? AND data->>'final_grade' = ? AND 
        data->>'classification' = ? AND
        data ->> 'claims_payment' = ? AND data ->> 'account_name' = ? AND data ->> 'account_number' = ?", 
        @claim.member_id, "KUYA JUN SCHOLARSHIP PROGRAM", @date_prepared, @amount, @name_of_beneficiary, @payee, 
        @name_of_school, @school_year, @year_level, @sem, @scholarship_type, 
        @final_grade, @classification, @claims_payment, @account_name, @account_number).count
        if count > 0
          @errors << "Duplicate SCHOLAR!"
        end
    end
  end
end
