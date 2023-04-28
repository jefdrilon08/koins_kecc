module DataStores
  class GenerateProjectTypeSummary
    def initialize
      @alist = Member.where(branch_id: "18cebed1-4838-4335-9023-ffd35c5e2629", status: "active")
      @p = ProjectTypeCategory.where(is_active: true)
      @data_category = []
      @data = []
    end

    def execute!

      @p.each do |pd|

      
        iter = 0
        tmp = []
        @alist.each do |a|
          a_data = a.data.with_indifferent_access
          if a_data[:project_type].present?
            c = a_data[:project_type].select{ |a| a[:project_type_category_id] == pd.id  }
            if c.count > 0
              iter = iter + c.count
              tmp <<  {last_name: a.last_name, first_name: a.first_name, project_type: c}
            end
          end
        end
        

        temp = { category: pd.name, category_id: pd.id, count: iter, member: tmp  }
        @data_category << temp
      end

      @p.each do |pdd|
        g = @data_category.select{ |a| a[:category_id] == pdd.id }
        h = g.map{ |f| f[:member]  }
        tmp3 = []
        dettmp = ""
        ProjectType.where(project_type_category_id: pdd.id, is_active: true).each do |pt|
         iter = 0
         tmp2 = []
         
          mem = h[0].map{ |l|
                    


                              c =  l.fetch(:project_type).select{ |h| h[:project_type_id] == pt.id}

                              if c.count > 0
                                tmp = { last_name: l.fetch(:last_name),  
                                      first_name:l.fetch(:first_name) 
                                    } 
                                    tmp 
                                tmp2 << { member: tmp, ptype: c.last  }
                                iter = iter + c.count
                              end
                        }


          tmp3 << { det: pt.name, i: iter, name: tmp2 }
          

        end

        
        @data << { categ: tmp3}


      end

      @data


    end
    

  end
end
