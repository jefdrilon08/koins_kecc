module DataStores
  class SavePatronageRefund
    def initialize(config:)
      @config = config
      @branch = @config[:branch]

      @start_date   = @config[:start_date]
      @end_date     = @config[:end_date]
      @equity_rate  = @config[:equity_rate]

      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::Accounting::GeneratePatronageRefund.new(
                      start_date: @start_date,
                      end_date: @end_date,
                      patronage_rate: @equity_rate,
                      branch_id: @branch.id
                    ).execute!

      @data_store.update!(
        data: data_result,
        status: "done"
      )

      @data_store
    end
  end
end
