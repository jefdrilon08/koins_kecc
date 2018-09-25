module Loaders
  class InsertClustersFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Cluster.transaction do
        columns = [
          :id,
          :name,
          :short_name,
          :area_id
        ]

        Cluster.import columns, @data[:clusters]
      end
    end
  end
end
