module Loaders
  class InsertAreasFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Area.transaction do
        columns = [
          :id,
          :name,
          :short_name
        ]

        Area.import columns, @data[:areas]
      end
    end
  end
end
