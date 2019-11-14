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
        if hiip_claim.policy_number == @hiip_claim.policy_number
          @hiip_claim.effective_date_of_coverage = HiipClaim.where(member_id: hiip_claim.member_id).order('created_at ASC').first.effective_date_of_coverage 
          @hiip_claim.expiration_date_of_coverage = HiipClaim.where(member_id: hiip_claim.member_id).order('created_at ASC').first.expiration_date_of_coverage 
          @hiip_claim.balance = @hiip_claim.balance - hiip_claim.amount
            if @hiip_claim.amount > 6000 || @hiip_claim.balance < 0
              @errors << "Exceed amount limit"
            end
        else
          hiip_claim.balance = 6000 - hiip_claim.amount
            if @hiip_claim.amount > 6000
              @errors << "Exceed amount limit"
            end
        end
        
      end    
    end
  end
end
