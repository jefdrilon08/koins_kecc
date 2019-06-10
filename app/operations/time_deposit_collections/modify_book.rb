module TimeDepositCollections
  class ModifyBook < AppValidator
    def initialize(config:)
      super()
      @config = config

      @book                     = @config[:book]
      @time_deposit_collection  = @config[:time_deposit_collection]
      @data                     = @time_deposit_collection.data.with_indifferent_access
      @accounting_entry         = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:book]  = @book
      @data[:accounting_entry]  = @accounting_entry

      @time_deposit_collection.update!(data: @data)

      @time_deposit_collection
    end
  end
end
