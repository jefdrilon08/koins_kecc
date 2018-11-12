module DataStores
  class SaveBranchLoansStats
    def initialize(config:)
      @config = config

      @data_store = DataStore.new
      @as_of      = @config[:as_of].try(:to_date) || Date.today
      @branch     = @config[:branch]

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
          data_store_type: "BRANCH_LOANS_STATS",
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
      config  = {
        branch: @branch,
        as_of: @as_of,
        include_centers: @include_centers
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
