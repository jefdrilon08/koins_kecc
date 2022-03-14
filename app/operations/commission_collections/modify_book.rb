module CommissionCollections
  class ModifyBook
    def initialize(config:)
      super()
      @config = config

      @book                   = @config[:book]
      @commission_collection  = @config[:commission_collection]
      @data                   = @commission_collection.data.with_indifferent_access
      @accounting_entry       = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:book]  = @book

      @data[:accounting_entry]  = @accounting_entry

      @commission_collection.update!(data: @data)

      @commission_collection
    end
  end
end
