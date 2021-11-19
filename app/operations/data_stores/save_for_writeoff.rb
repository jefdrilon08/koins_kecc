module DataStores
  class SaveForWriteoff
    def initialize(config:)
      @config     = config
      @year       = @config[:year]
      @number_of_years = @config[:number_of_years]
      @branch     = @config[:branch]
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
    end

    def execute!
    
      data_result = ::DataStores::GenerateForWriteoff.new(
                      config: {
                        year: @year,
                        number_of_year: @number_of_years,
                        branch: @branch
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
