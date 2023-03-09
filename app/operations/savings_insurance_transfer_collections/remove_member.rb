module SavingsInsuranceTransferCollections
  class RemoveMember
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @user                                   = @config[:user]
      @branch                                 = @savings_insurance_transfer_collection.branch
      @data                                   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)

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

      load_accounting_entry!
    end

    def load_accounting_entry!
      @data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @savings_insurance_transfer_collection.update!(
        data: @data
      )
      @savings_insurance_transfer_collection
    end
  end
end
