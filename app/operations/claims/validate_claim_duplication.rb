module Claims
  class ValidateClaimDuplication
    attr_accessor :claim, :errors

    def initialize(claim:)
      @claim = claim
      @errors = []
    end

    def execute!
      validate_claim_duplication!
      @errors
    end

    private

    def validate_claim_duplication!
      Claim.all.each do |claim|
        if claim.type_of_insurance_policy == @claim.type_of_insurance_policy && claim.classification_of_insured == @claim.classification_of_insured && claim.date_of_death_tpd_accident == @claim.date_of_death_tpd_accident && claim.policy_number == @claim.policy_number
          @errors << "Duplicate claims!"
        end
      end
    end
  end
end
