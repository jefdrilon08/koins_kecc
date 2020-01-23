module DataStores
  class SaveIcpr
    def initialize(config:)
      @config     = config
      @year       = @config[:year]
      @branch     = @config[:branch]
      @user       = @config[:user]
      @data_store = DataStore.find(@config[:id])
    end

    def execute!
      data_result = ::Accounting::GenerateIosc.new(
                      config: {
                        year: @year,
                        branch: @branch
                      }
                    ).execute!


      data_result[:accounting_entry]  = ::Icpr::BuildAccountingEntry.new(
                                          config: {
                                            branch: @branch,
                                            user: @user,
                                            data: data_result
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
