module Loaders
  class InsertCentersFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Center.transaction do
        columns = [
          :id,
          :name,
          :short_name,
          :branch_id
        ]

        Center.import columns, @data[:centers]
      end
    end
  end
end
