module Claims
  class ValidateClipClaimDuplication
    attr_accessor :clip_claim, :errors

    def initialize(clip_claim:)
      @clip_claim = clip_claim
      @errors = []
    end

    def execute!
      validate_clip_claim_duplication!
      @errors
    end

    private

    def validate_clip_claim_duplication!
      ClipClaim.all.each do |clip_claim|
        if clip_claim.member == @clip_claim.member && clip_claim.creditors_name == @clip_claim.creditors_name && clip_claim.date_of_death == @clip_claim.date_of_death && clip_claim.type_of_loan == @clip_claim.type_of_loan && clip_claim.amount_of_loan == @clip_claim.amount_of_loan
          @errors << "Duplicate clip claims!"
        end
      end
    end
  end
end
