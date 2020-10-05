module Claims
  class ValidateModifyClaimsTemplate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @template = @config[:template]
      @claim    = @config[:claim]
    end

    def execute!
      if @claim.blank?
        @errors << {
          name: "claim",
          message: "Claim not found"
        }
      # elsif !@claim.pending?
      #   @errors << {
      #     name: "claim",
      #     message: "Claim is not pending"
      #   }
      # elsif !@claim.checked?
      #   @errors << {
      #     name: "claim",
      #     message: "Claim is not check"
      #   }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
