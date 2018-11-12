module DataStores
  class SaveBranchLoansStats
    def initialize(config:)
      @config = config

      @data_store       = DataStore.new
      @as_of            = @config[:as_of].try(:to_date) || Date.today
      @branch           = @config[:branch]
      @data_store_type  = @config[:data_store_type] || "BRANCH_LOANS_STATS"

      @include_centers  = false

      if @config.has_key?(:include_centers)
        @include_centers  = @config[:include_centers]
      end

      if @config.has_key?(:id)
        @data_store = DataStore.find(config[:id])
      end

      if @data_store.new_record?
        @meta = {
          as_of: @as_of,
          branch_id: @branch.id,
          branch_name: @branch.name,
          data_store_type: @data_store_type,
          include_centers: @include_centers
        }

        @data = {
        }
      else
        @meta = @data_store.meta.with_indifferent_access
        @data = @data_store.data.with_indifferent_access
      end
    end

    def execute!
      include_loan_products = false

      if @data_store.meta.with_indifferent_access[:data_store_type] == "BRANCH_WITH_CENTERS_LOANS_STATS"
        include_loan_products = true
      end

      config  = {
        branch: @branch,
        as_of: @as_of,
        include_centers: @include_centers,
        include_loan_products: include_loan_products
      }

      # TODO: Thread this
      @data = ::Branches::ComputeLoansStatus.new(config: config).execute!

      @data_store.meta  = @meta
      @data_store.data  = @data
      @data_store.status  = "done"

      @data_store.save!

      @data_store
    end
  end
end
