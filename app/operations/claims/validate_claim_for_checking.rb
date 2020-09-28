module Claims
  class ValidateClaimForChecking < AppValidator

    def initialize(config:)
      super()

      @config = config

      @claim = @config[:claim]
    end

    def execute!
      if !@claim.pending?
        @errors[:messages] << {
          key: "claim",
          message: "Invalid status"
        }
      end

      @errors
    end
  end
end
