module SavingsInsuranceTransferCollections
  class Save
    def initialize(config:)
      @config             = config
      @branch             = @config[:branch]
      @center             = @config[:center]
      @collection_date    = @config[:collection_date]
      @savings_subtype    = @config[:savings_subtype]
      @insurance_subtype  = @config[:insurance_subtype]
      @user               = @config[:user]

      @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.new(
                                                  branch: @branch,
                                                  center: @center,
                                                  collection_date: @collection_date,
                                                  data: {
                                                    savings_subtype: @savings_subtype,
                                                    insurance_subtype: @insurance_subtype,
                                                    records: []
                                                  }
                                                )

      @savings_insurance_transfer_collection.data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                                                          config: {
                                                                            branch: @branch,
                                                                            data: @savings_insurance_transfer_collection.data.with_indifferent_access,
                                                                            user: @user
                                                                          }
                                                                        ).execute!
    end

    def execute!
      @savings_insurance_transfer_collection.save!

      @savings_insurance_transfer_collection
    end
  end
end
