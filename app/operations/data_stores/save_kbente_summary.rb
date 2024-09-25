module DataStores
  class SaveKbenteSummary
    def initialize(config:)
      @config   = config
      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today

      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::Branches::FetchKbenteSummary.new(
                      config: {
                        branch: @branch,
                        as_of: @as_of
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