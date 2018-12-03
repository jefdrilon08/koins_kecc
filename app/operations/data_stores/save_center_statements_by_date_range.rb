module DataStores
  class SaveCenterStatementsByDateRange
    def initialize(config:)
      @config = config

      @data_store = DataStore.new
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @center     = @config[:center]

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          start_date: @start_date,
          end_date: @end_date,
          center: {
            id: @center.id,
            name: @center.name
          },
          branch: {
            id: @center.branch.id,
            name: @center.branch.name
          }
        }

        @data = {
        }
      else
        @meta = @data_store.meta.with_indifferent_access
        @data = @data_store.data.with_indifferent_access
      end
    end

    def execute!
      @meta[:data_store_type] = "CENTER_STATEMENTS_BY_DATE_RANGE"

      config  = {
        center: @center,
        start_date: @start_date,
        end_date: @end_date
      }

      @data = ::MemberAccounts::CreateStatementsByDateRange.new(config: config).execute!

      @data_store.meta    = @meta
      @data_store.data    = @data
      @data_store.status  = "done"

      @data_store.save!

      @data_store
    end
  end
end
