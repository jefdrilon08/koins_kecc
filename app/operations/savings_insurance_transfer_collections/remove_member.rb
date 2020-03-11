module SavingsInsuranceTransferCollections
  class RemoveMember
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]

      @data = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)

      @savings_subtype    = @data[:savings_subtype]
      @insurance_subtype  = @data[:insurance_subtype]
    end

    def execute!
      @data[:records] = @data[:records].select{ |o|
                          o[:member][:id] != @member.id
                        }

      total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.to_f.round(2)

      @savings_insurance_transfer_collection.update!(data: @data, total_amount: total_amount)

      @savings_insurance_transfer_collection
    end
  end
end
