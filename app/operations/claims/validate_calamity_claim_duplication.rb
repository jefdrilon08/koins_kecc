module Claims
  class ValidateCalamityClaimDuplication
    attr_accessor :calamity_claim, :errors

    def initialize(calamity_claim:)
      @calamity_claim = calamity_claim
      @errors = []
    end

    def execute!
      validate_calamity_claim_duplication!
      @errors
    end

    private

    def validate_calamity_claim_duplication!
      CalamityClaim.all.each do |calamity_claim|
        if calamity_claim.member == @calamity_claim.member 
          @errors << "Duplicate claims!"
        end
      end
    end
  end
end
