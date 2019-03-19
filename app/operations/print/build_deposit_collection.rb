module Print
  class BuildDepositCollection
    def initialize(config:)
      @config             = config
      @deposit_collection = @config[:deposit_collection]

      @data = {
        branch: {
          id: @deposit_collection.branch.id,
          name: @deposit_collection.branch.name
        },
        collection_date: @deposit_collection.collection_date,
        data: @deposit_collection[:data].with_indifferent_access
      }
    end

    def execute!
      @data
    end
  end
end
