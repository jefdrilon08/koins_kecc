module SavingsInsuranceTransferCollections
  class ValidateUpdateOrArNumber < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @ar_number                             = @config[:ar_number]
      @or_number                             = @config[:or_number]

      # raise @or_number.inspect
    end

    def execute!
      if !@ar_number.present? || !@or_number.present?
        @errors[:messages] << {
          key: "ar/or_number",
          message: " Ar/Or is required"
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
