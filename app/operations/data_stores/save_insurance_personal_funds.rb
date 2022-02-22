module DataStores
  class SaveInsurancePersonalFunds
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @member_status = @config[:member_status]
      @as_of  = @config[:as_of].try(:to_date) || Date.today

      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::Branches::ComputeInsurancePersonalFunds.new(
                      config: {
                        branch: @branch,
                        as_of: @as_of,
                        member_status: @member_status,
                        data_store_id: @config[:id]
                      }
                    ).execute!

      @data_store.update!(
        data: data_result,
        status: "done"
      )

      @data_store
    end
  end
end
