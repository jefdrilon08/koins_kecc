module DataStores
  class SaveWatchlist
    def initialize(config:)
      @config = config

      @data_store       = DataStore.new
      @as_of            = @config[:as_of]
      @branch           = @config[:branch]
      @data_store_type  = @config[:data_store_type] || "WATCHLIST"

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          as_of: @as_of,
          branch_id: @branch.id,
          branch_name: @branch.name,
          data_store_type: @data_store_type,
        }        

        @data = {
          status: "processing"
        }
      else
        @meta = @data_store.meta.with_indifferent_access
        @data = @data_store.data.with_indifferent_access
      end
    end

    def execute!
      config  = {
        branch: @branch,
        as_of: @as_of
      }

      @data = ::Branches::ComputeWatchlist.new(config: config).execute!

      @data_store.meta    = @meta
      @data_store.data    = @data
      @data_store.status  = "done"

      @data_store.save!

      @data_store
    end
  end
end
