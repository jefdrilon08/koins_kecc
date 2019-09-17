module Claims
  class ValidateHiipClaimDuplication
    attr_accessor :clip_claim, :errors

    def initialize(hiip_claim:)
      @hiip_claim = hiip_claim
      @errors = []
    end

    def execute!
      validate_hiip_claim_duplication!
      @errors
    end

    private

    def validate_hiip_claim_duplication!
      HiipClaim.all.each do |hiip_claim|
        if hiip_claim.member == @hiip_claim.member 
          @errors << "Duplicate HIIP!" 
        end
      end
    end
  end
end
