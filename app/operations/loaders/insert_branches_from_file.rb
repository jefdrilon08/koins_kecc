module Loaders
  class InsertBranchesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Branch.transaction do
        columns = [
          :id,
          :name,
          :short_name,
          :cluster_id
        ]

        Branch.import columns, @data[:branches]
      end
    end
  end
end
