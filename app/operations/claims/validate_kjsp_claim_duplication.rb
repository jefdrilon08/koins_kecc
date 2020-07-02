module Claims
  class ValidateKjspClaimDuplication
    attr_accessor :kjsp_claim, :errors

    def initialize(kjsp_claim:)
      @kjsp_claim = kjsp_claim
      @errors = []
    end

    def execute!
      #validate_kjsp_claim_duplication!
      @errors
    end

    private

    def validate_kjsp_claim_duplication!
      KjspClaim.all.each do |kjsp_claim|
        if kjsp_claim.member == @kjsp_claim.member 
          @errors << "Duplicate claims!"
        end
      end
    end
  end
end
