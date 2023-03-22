module DataStores
  class GenerateProjectTypeSummary
    def initialize
      @data = {
        records: []

      }
      @project_type = ProjectType.where(is_active: true)
      @project_type_category = ProjectTypeCategory.where(is_active: true) 
    
   end

    def execute!
      query!


    
      @project_type_category.map { |a| 

      a[:id]


      g = @result.select{ |o| o["project_type"]["project_type_categor"] == '68b0a0c3-9786-4ca3-96e3-31dddf1bb6e6'}

       raise g.inspect
        


      }



    end
    
    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT
          m.first_name,
          m.last_name,
          m.middle_name,
          m.data->'project_type' as project_type
        FROM Members m
        WHERE
          m.branch_id = '339144e0-9544-4a7a-b2d4-b500cc329034' and
          m.data->'project_type' IS NOT NULL and
          m.status = 'active'

      EOS
    end

  end
end
