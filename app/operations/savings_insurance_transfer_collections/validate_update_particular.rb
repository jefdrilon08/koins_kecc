module SavingsInsuranceTransferCollections
  class ValidateUpdateParticular < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @particular                             = @config[:particular]
    end

    def execute!
      if !@particular.present?
        @errors[:messages] << {
          key: "particular",
          message: "Particular is required"
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
