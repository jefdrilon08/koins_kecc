module Claims
  class DeclinedClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @declined_note     = @config[:declined_note]
      @claim_data        = @claim.data.with_indifferent_access
    end

    def execute!
      @claim_data[:for_proceed] = false
      @claim_data[:declined_note] = @declined_note
      @claim.update!(data: @claim_data)

      @claim
    end
  end
end
