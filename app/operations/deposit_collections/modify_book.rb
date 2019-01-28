module DepositCollections
  class ModifyBook < AppValidator
    def initialize(config:)
      super()
      @config = config

      @book           = @config[:book]
      @deposit_collection = @config[:deposit_collection]
      @data               = @deposit_collection.data.with_indifferent_access
      @accounting_entry   = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:book]  = @book
      @data[:accounting_entry]  = @accounting_entry

      @deposit_collection.update!(data: @data)

      @deposit_collection
    end
  end
end
