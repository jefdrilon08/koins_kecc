module DataStores
  class SaveForWriteoff
    def initialize(config:)
      @config     = config
      @year       = @config[:year]
      @number_years = @config[:number_of_years]
      @branch     = @config[:branch]
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
    end

    def execute!
    
      data_result = ::DataStores::GenerateForWriteoff.new(
                      config: {
                        year: @year,
                        branch: @branch,
                        number_years: @number_years
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
