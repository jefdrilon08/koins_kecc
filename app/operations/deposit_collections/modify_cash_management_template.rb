module DepositCollections
  class ModifyCashManagementTemplate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @template           = @config[:template]
      @deposit_collection = @config[:deposit_collection]
      @data               = @deposit_collection.data.with_indifferent_access
    end

    def execute!
      @data[:cash_management_template]  = @template

      @deposit_collection.update!(data: @data)

      @deposit_collection
    end
  end
end
