module DataStores
  class SaveBranchResignation
    def initialize(config:)
      @config = config

      @data_store       = DataStore.new
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]
      @branch           = @config[:branch]
      @data_store_type  = "BRANCH_RESIGNATIONS"

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          start_date: @start_date,
          end_date: @end_date,
          data_store_type: @data_store_type,
          branch: {
            id: @branch.id,
            name: @branch.name
          }
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
      data_result = ::Members::GenerateResignationData.new(
                      config: {
                        start_date: @start_date,
                        end_date: @end_date,
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
