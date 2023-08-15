module SavingsInsuranceTransferCollections
  class UpdateOrArNumber
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @ar_number                             = @config[:ar_number]
      @or_number                             = @config[:or_number]
      @user                                   = @config[:user]

      @data   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      @data[:accounting_entry][:data][:or_number] = @or_number
      @data[:accounting_entry][:data][:ar_number] = @ar_number

      @savings_insurance_transfer_collection.update!(data: @data)

      @savings_insurance_transfer_collection
    end
  end
end
