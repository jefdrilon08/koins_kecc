module DepositCollections
  class ModifyCashManagementTemplate
    def initialize(config:)
      @config = config

      @template           = @config[:template]
      @deposit_collection = @config[:deposit_collection]
      @user               = @config[:user]
      @data               = @deposit_collection.data.with_indifferent_access
    end

    def execute!
      @data[:cash_management_template]  = @template

      config  = {
        deposit_collection: @deposit_collection,
        branch: @deposit_collection.branch,
        user: @user,
        collection_date: @deposit_collection.collection_date,
        data: @data
      }

      @data[:accounting_entry]  = ::DepositCollections::BuildAccountingEntry.new(
                                    config: config
                                  ).execute!

      @deposit_collection.update!(data: @data)
    
      @deposit_collection
    end
  end
end
