module DataStores
  class ApproveProjectTypes
    def initialize(config:)
      @data_store = DataStore.find(config[:data_store_id])
      @data_store_data = @data_store.data
    end
    def execute!
      @data_store_data.each do |dsd|
        tmp = {
          project_type_id: dsd["project_type_id"],
          project_type_category_id: dsd["project_type_category_id"],
          details: {
            project_type: dsd["details"]["project_type"],
            project_type_category: dsd["details"]["project_type_category"],
            latitude_data: dsd["details"]["latitude_data"],
            longtitude_data: dsd["details"]["longtitude_data"]


          }

        }
        
        m = Member.find(dsd["member_id"])
        m_data =  m.data.with_indifferent_access
        
        if m_data[:project_type].present?
      
          m_data[:project_type] << tmp
        else
          
          m_data[:project_type] = []
          m_data[:project_type] << tmp
        end

        m.update!(data: m_data)

      end

      @data_store.update!(status: "approved")


    
      @data_store

    
    end
  end
end
