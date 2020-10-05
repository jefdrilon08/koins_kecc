module Claims
  class ValidateModifyParticular < AppValidator
    def initialize(config:)
      super()
      @config = config

      @particular  = @config[:particular]
      @claim       = @config[:claim]
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
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
