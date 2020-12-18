module Claims
  class ProceedClaim
    def initialize(config:)
      @config            = config

      @claim             = @config[:claim]
      @claim_data        = @claim.data.with_indifferent_access
    end

    def execute!
      @claim_data[:for_proceed] = true

      if @claim.declined_note.present?
        @claim_data[:declined_note] = nil
      end

      @claim.update!(data: @claim_data)

      @claim
    end
  end
end
