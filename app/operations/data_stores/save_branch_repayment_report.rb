module DataStores
  class SaveBranchRepaymentReport
    def initialize(config:)
      @config = config

      @data_store       = DataStore.new
      @as_of            = @config[:as_of].try(:to_date) || Date.today
      @branch           = @config[:branch]
      @data_store_type  = "BRANCH_REPAYMENT_REPORT"

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          as_of: @as_of,
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
      data_result = ::Reports::GenerateRepaymentReport.new(
                      config: {
                        as_of: @as_of,
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
