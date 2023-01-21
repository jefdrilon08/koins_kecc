module DataStores
  class SaveMembersProjectTypes
    def initialize(config:)
      project_type = ProjectType.find(config[:project_type_id])
      
      project_type_category = ProjectTypeCategory.find(config[:project_category_id])
      
      member = Member.find(config[:member_id])
      @data_store = DataStore.find(config[:data_store_id])
      #@data_store_data = @data_store.data = {records: []  }
      @data_store_data = @data_store.data
      @data = {
        project_type_id: project_type.id,
        project_type_category_id: project_type_category.id,
        member_id: member.id,
        details: {
          project_type: project_type.name,
          project_type_category: project_type_category.name,
          member: member.full_name
        }

      }
          
    end
    def execute!
    
      
      @data_store_data << @data
      
    

      @data_store.update!(data: @data_store_data)
     
     @data
    end
  end
end
