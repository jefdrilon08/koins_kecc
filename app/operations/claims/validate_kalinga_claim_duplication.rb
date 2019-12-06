module Claims
  class ValidateKalingaClaimDuplication
    attr_accessor :kalinga_claim, :errors

    def initialize(kalinga_claim:)
      @kalinga_claim = kalinga_claim
      @errors = []
    end

    def execute!
      validate_kalinga_claim_duplication!
      @errors
    end

    private

    def validate_kalinga_claim_duplication!
      KalingaClaim.all.each do |kalinga_claim|
        if kalinga_claim.id == @kalinga_claim.id 
          @errors << "Duplicate clip claims!"
        end
      end
    end
  end
end
