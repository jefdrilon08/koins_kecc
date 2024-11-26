module Claims
  class ValidateBlip

    # def initialize(data:, gender:, date_prepared:, policy_number:, type_of_insurance_policy:, name_of_insured:, beneficiary:, classification_of_insured:, date_of_birth:, date_of_policy_issue:, face_amount:, date_of_death_tpd_accident:, arrears:, cause_of_death_tpd_accident:, equity_value:, retirement_fund:, prepared_by:, length_of_stay:, returned_contribution:, total_amount_payable:, order_of_child:, category_of_cause_of_death_tpd_accident:, date_reported:, date_paid:, age: )
      def initialize(data:, date_prepared:, prepared_by:, claim:, control:)
        @claim                                    = claim
        @data                                     = data
        @date_prepared                            = date_prepared
        @prepared_by                              = prepared_by
        @amount                                   = @data[:amount]
        @gender                                   = @data[:gender]
        @policy_number                            = @data[:policy_number]
        @type_of_insurance_policy                 = @data[:type_of_insurance_policy]
        @name_of_insured                          = @data[:name_of_insured]
        @beneficiary                              = @data[:beneficiary]
        @classification_of_insured                = @data[:classification_of_insured]
        @date_of_birth                            = @data[:date_of_birth]
        @date_of_policy_issue                     = @data[:date_of_policy_issue]
        @face_amount                              = @data[:face_amount]
        @date_of_death_tpd_accident               = @data[:date_of_death_tpd_accident]
        @arrears                                  = @data[:arrears]
        @cause_of_death_tpd_accident              = @data[:cause_of_death_tpd_accident]
        @equity_value                             = @data[:equity_value]
        @retirement_fund                          = @data[:retirement_fund]
        @length_of_stay                           = @data[:length_of_stay]
        @returned_contribution                    = @data[:returned_contribution]
        @order_of_child                           = @data[:order_of_child]
        @category_of_cause_of_death_tpd_accident  = @data[:category_of_cause_of_death_tpd_accident]
        @date_reported                            = @data[:date_reported]
        @date_paid                                = @data[:date_paid]
        @age                                      = @data[:age]
        @claims_payment                           = @data[:claims_payment]
        @account_name                             = @data[:account_name]
        @account_number                           = @data[:account_number]
        @control                                  = control

        @errors = []
    end

    def execute!

      if @gender.blank?
        @errors << "Gender field is required"
      end

      if @date_prepared.blank?
        @errors << " Date Processed field is required"
      end

      if @policy_number.blank?
        @errors << "Policy Number field is required"
      end

      if @type_of_insurance_policy.blank?
        @errors << "Type of Insurance Policy field is required"
      end

      if @name_of_insured.blank?
        @errors << "Name of Insured field is required"
      end

      if @beneficiary.blank?
        @errors << "Beneficiary field is required"
      end

      if @classification_of_insured.blank?
        @errors << "Classification of Insured field is required"
      end

      if @date_of_birth.blank?
        @errors << "Date of Birth field is required"
      end

      if @date_of_policy_issue.blank?
        @errors << "Date of Policy field is required"
      end

      if @face_amount.blank?
        @errors << "Face Amount field is required"
      end

      if @date_of_death_tpd_accident.blank?
        @errors << "Date of Death/TPD/Accident field is required"
      end

      if @arrears.blank?
        @errors << "Lapsed Amount field is required"
      end

      if @cause_of_death_tpd_accident.blank?
        @errors << "Cause of Death/TPD/Accident field is required"
      end

      if @equity_value.blank?
        @errors << "Equity Value field is required"
      end

      if @retirement_fund.blank?
        @errors << "Retirement Fund field is required"
      end

      if @prepared_by.blank?
        @errors << "Prepared By field is required"
      end

      if @length_of_stay.blank?
        @errors << "Length of Stay field is required"
      end

      if @returned_contribution.blank?
        @errors << "Returned Contribution field is required"
      end

      if @amount.blank?
        @errors << "Total Amount Payable field is required"
      end

      # if @order_of_child.blank?
      #   @errors << "Order of Child field is required"
      # end

      if @category_of_cause_of_death_tpd_accident.blank?
        @errors << "Category of Cause of Death/TPD/Accident field is required"
      end

      if @date_reported.blank?
        @errors << "Date Reported field is required"
      end


      if @classification_of_insured == "Legal Dependent (Parent)" && @age.to_i < 60
        @errors << "Age for Legal Dependent (Parent) classification should be 60 or above. Current age: #{@age}"
      end

      # if @date_paid.blank?
      #   @errors << "Date Paid field is required"
      # end

      # if @claims_payment.blank?
      #   @errors << "Claims Payment field is required"
      # end

      # if @account_name.blank?
      #   @errors << "Account name field is required"
      # end

      # if @account_number.blank?
      #   @errors << "Account number field is required"
      # end


      validate_blip_duplication!
      return  @errors
    end

    private

    def validate_blip_duplication!
      @count = 0

      if @control == "new"
        @count = Claim.where("data->>'date_of_policy_issue' = ?
                          AND data->>'type_of_insurance_policy' = ?
                          AND data->>'classification_of_insured' = ?
                          AND data->>'date_of_death_tpd_accident' = ?
                          AND data->>'policy_number' = ?
                          AND data->>'date_of_birth' = ?
                          AND data->>'gender' = ?",
                          @date_of_policy_issue,
                          @type_of_insurance_policy,
                          @classification_of_insured,
                          @date_of_death_tpd_accident,
                          @policy_number,
                          @date_of_birth,
                          @gender).count
      end

      if @count > 0
        @errors << "Duplicate BLIP!"
      end
    end
  end
end
