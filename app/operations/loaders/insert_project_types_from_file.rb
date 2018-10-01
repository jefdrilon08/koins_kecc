module Loaders
  class InsertProjectTypesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      ProjectType.transaction do
        columns = [
          :id, 
          :name, 
          :code,
          :project_type_category_id
        ]

        ProjectType.import columns, @data[:project_types]
      end
    end
  end
end
