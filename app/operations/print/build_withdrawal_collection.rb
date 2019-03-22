module Print
  class BuildWithdrawalCollection
    def initialize(config:)
      @config             = config
      @withdrawal_collection = @config[:withdrawal_collection]

      @data = {
        branch: {
          id: @withdrawal_collection.branch.id,
          name: @withdrawal_collection.branch.name
        },
        collection_date: @withdrawal_collection.collection_date,
        data: @withdrawal_collection[:data].with_indifferent_access
      }
    end

    def execute!
      @data
    end
  end
end
