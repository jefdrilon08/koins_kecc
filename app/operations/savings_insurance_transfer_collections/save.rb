module SavingsInsuranceTransferCollections
  class Save
    def initialize(config:)
      if !Settings.activate_microinsurance
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
      else
        @config             = config
        @branch             = @config[:branch]
        @center             = @config[:center]
        @collection_date    = @config[:collection_date]
        @payment_subtype    = @config[:payment_subtype]
        @or_number          = @config[:or_number]
        @ar_number          = @config[:ar_number]
        @insurance_subtype  = @config[:insurance_subtype]
        @user               = @config[:user]

        @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.new(
                                                    branch: @branch,
                                                    center: @center,
                                                    collection_date: @collection_date,
                                                    data: {
                                                      payment_subtype:  @payment_subtype,
                                                      ar_number: @ar_number,
                                                      or_number: @or_number,
                                                      insurance_subtype: @insurance_subtype,
                                                      records: []
                                                    }
                                                  )
        if @branch != "3a74c7d5-54a5-4eec-826d-ab81f76ae31a" && @center != "5feb513d-6963-4b30-acdc-7630da3aef13" && @insurance_subtype != "Credit Life Insurance Plan"
          @savings_insurance_transfer_collection.data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                                                              config: {
                                                                                branch: @branch,
                                                                                data: @savings_insurance_transfer_collection.data.with_indifferent_access,
                                                                                user: @user
                                                                              }
                                                                            ).execute!
        end
        
      end
    end

    def execute!
      @savings_insurance_transfer_collection.save!

      @savings_insurance_transfer_collection
    end
  end
end