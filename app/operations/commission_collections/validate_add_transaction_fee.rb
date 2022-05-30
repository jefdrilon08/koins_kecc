module CommissionCollections
  class ValidateAddTransactionFee < AppValidator
    def initialize(config:)
      super()
      @config                = config

      @transaction_fee       = @config[:transaction_fee]
      @commission_collection = @config[:commission_collection]
    end

    def execute!
      if @commission_collection.blank?
        @errors << {
          name: "commission_collection",
          message: "Commission collection not found"
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
