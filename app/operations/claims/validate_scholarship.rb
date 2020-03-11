module Claims
  class ValidateScholarship

    def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                    = claim
        @data                     = data
        @date_prepared            = date_prepared
        @prepared_by              = prepared_by
        @name_of_beneficiary      = @data[:name_of_beneficiary]
        @payee                    = @data[:payee]
        @amount                   = @data[:amount]
        @name_of_school           = @data[:name_of_school]
        @school_year              = @data[:school_year]
        @year_level               = @data[:year_level]
        @sem                      = @data[:sem]
        @scholarship_type         = @data[:scholarship_type]
        @final_grade              = @data[:final_grade]
        @classification           = @data[:classification]
        @course                   = @data[:course]

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

      validate_scholar_duplication!
      return  @errors
    end

   private

    def validate_scholar_duplication!
      count = Claim.where("claim_type = ? AND data->>'name_of_beneficiary' = ? AND data->>'school_year' = ?", "KUYA JUN SCHOLARSHIP PROGRAM", @name_of_beneficiary, @school_year).count
      if count > 0
        @errors << "Duplicate SCHOLAR!"
      end
    end
  end
end
