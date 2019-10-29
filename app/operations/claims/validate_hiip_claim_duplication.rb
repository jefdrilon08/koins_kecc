module Claims
  class ValidateHiipClaimDuplication
    attr_accessor :hiip_claim, :errors

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
      # if @hiip_claim.member == hiip_claim.member
      #   @hiip_claim.balance = @hiip_claim.balance - @hiip_claim.amount
      # end
      if @hiip_claim.amount > 6000
          @errors << "Exceed amount limit"
      end
      end    
    end
  end
end
