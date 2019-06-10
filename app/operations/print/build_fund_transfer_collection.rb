module Print
  class BuildFundTransferCollection
    def initialize(config:)
      @config             = config
      @insurance_fund_transfer_collection = @config[:insurance_fund_transfer_collection]

      @data = {
        branch: {
          id: @insurance_fund_transfer_collection.branch.id,
          name: @insurance_fund_transfer_collection.branch.name
        },
        collection_date: @insurance_fund_transfer_collection.collection_date,
        data: @insurance_fund_transfer_collection[:data].with_indifferent_access
      }
    end

    def execute!
      @data
    end
  end
end
