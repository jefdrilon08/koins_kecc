module Claims
  class ValidateAddTransactionFee < AppValidator
    def initialize(config:)
      super()
      @config          = config

      @transaction_fee = @config[:transaction_fee]
      @claim           = @config[:claim]
    end

    def execute!
      if @claim.blank?
        @errors << {
          name: "claim",
          message: "Claim not found"
        }
      end

      if @transaction_fee < 0
        @errors << {
          name: "transaction_fee",
          message: "Transaction Fee must be greater than zero."
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
