module Claims
  class ValidateClaimForDeclining < AppValidator

    def initialize(config:)
      super()

      @config        = config

      @claim         = @config[:claim]
      @declined_note = @config[:declined_note]
    end

    def execute!
      if !@claim.proceed_checking?
        @errors[:messages] << {
          key: "claim",
          message: "Claim must for proceed!"
        }
      end

      if @declined_note.nil?
        @errors[:messages] << {
          key: "claim",
          message: "Note is blank!"
        }
      end      

      @errors
    end
  end
end
