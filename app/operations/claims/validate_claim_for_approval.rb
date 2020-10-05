module Claims
  class ValidateClaimForApproval < AppValidator

    def initialize(config:)
      super()

      @config = config

      @claim = @config[:claim]
    end

    def execute!
      if !@claim.for_approval?
        @errors[:messages] << {
          key: "claim",
          message: "Invalid status"
        }
      end

      @errors
    end
  end
end
