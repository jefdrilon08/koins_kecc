module DataStores
  class SaveSoaExpenses
    def initialize(config:)
      @config = config

      @data_store       = DataStore.new
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]
      @branch           = @config[:branch]
      @data_store_type  = @config[:data_store_type] || "SOA_EXPENSES"

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          start_date: @start_date,
          end_date: @end_date,
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
        start_date: @start_date,
        end_date: @end_date
      }

      @data = ::Branches::ComputeSoaExpenses.new(config: config).execute!

      @data_store.meta  = @meta
      @data_store.data  = @data
      @data_store.status  = "done"

      @data_store.save!

      @data_store
    end
  end
end
