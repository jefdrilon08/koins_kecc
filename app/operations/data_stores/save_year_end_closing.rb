module DataStores
  class SaveYearEndClosing
    def initialize(config:)
      @config       = config
      @branch       = @config[:branch]
      @user         = @config[:user]
      @closing_date = @config[:closing_date]
      @year         = @config[:year]

      @accounting_fund  = @config[:accounting_fund] || nil

      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::Closing::ComputeYearEndClosing.new(
                      config: {
                        closing_date: @closing_date,
                        year: @year,
                        user: @user,
                        branch: @branch,
                        accounting_fund: @accounting_fund
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
