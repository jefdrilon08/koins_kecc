module SavingsInsuranceTransferCollections
  class UpdateParticular
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @particular                             = @config[:particular]
      @user                                   = @config[:user]

      @data   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      @data[:accounting_entry][:particular] = @particular

      @savings_insurance_transfer_collection.update!(data: @data)

      @savings_insurance_transfer_collection
    end
  end
end
