module DataStores
  class SaveMigs
    def initialize(config:)
      @config     = config
      @year       = @config[:year]
      @branch     = @config[:branch]
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::DataStores::GenerateMigs.new(
                      config: {
                        year: @year,
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
