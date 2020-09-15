module Claims
  class ValidateKbenteClaimDuplication
    attr_accessor :kbente_claim, :errors

    def initialize(kbente_claim:)
      @kbente_claim = kbente_claim
      @errors = []
    end

    def execute!
      #validate_kbente_claim_duplication!
      @errors
    end

    private

    def validate_kbente_claim_duplication!
      KbenteClaim.all.each do |kbente_claim|
        if kbente_claim.member == @kbente_claim.member 
          @errors << "Duplicate claims!"
        end
      end
    end
  end
end
