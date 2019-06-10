module Print
  class BuildTimeDepositCollection
    def initialize(config:)
      @config             = config
      @time_deposit_collection = @config[:time_deposit_collection]

      @data = {
        branch: {
          id: @time_deposit_collection.branch.id,
          name: @time_deposit_collection.branch.name
        },
        collection_date: @time_deposit_collection.collection_date,
        data: @time_deposit_collection[:data].with_indifferent_access
      }
    end

    def execute!
      @data
    end
  end
end
