module Loaders
  class InsertProjectTypeCategoriesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      ProjectTypeCategory.transaction do
        columns = [
          :id, 
          :name, 
          :code,
          :is_active
        ]

        ProjectTypeCategory.import columns, @data[:project_type_categories]
      end
    end
  end
end
