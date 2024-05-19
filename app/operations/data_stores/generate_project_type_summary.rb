module DataStores
  class GenerateProjectTypeSummary
    
    def initialize(branch_id:)
  
      @branch_id = branch_id
      #@alist = Member.where(branch_id: @branch_id, status: "active")
      @alist = Member.where(status: "active")
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
              t_portfolio = Loan.where(member_id: a.id, status: "active").sum(:principal_balance)
              tmp <<  {last_name: a.last_name, first_name: a.first_name, center_id: a.center_id ,project_type: c, total_portfolio: t_portfolio}
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
          gtotal_portfolio = 0.0
         
          mem = h[0].map{ |l|
                              c =  l.fetch(:project_type).select{ |h| h[:project_type_id] == pt.id}
                              if c.count > 0
                                tmp = { last_name: l.fetch(:last_name),  
                                        first_name:l.fetch(:first_name),
                                        center_id: l.fetch(:center_id),
                                        total_portfolio: l.fetch(:total_portfolio)
                                      } 
                                tmp 
                                tmp2 << { member: tmp, ptype: c.last  }
                                iter = iter + c.count
                                gtotal_portfolio = gtotal_portfolio.to_f + l.fetch(:total_portfolio).to_f
                              end
                        }
          
          tmp3 << { det_id: pt.id, det: pt.name, i: tmp2.count, memDet: tmp2, grand_portfolio: gtotal_portfolio  }
          #tmp3 << { det_id: pt.id, det: pt.name, i: tmp2.count  }
          

        end
      
        #raise tmp3.sum{ |a| a[:i] }.inspect
        @data << { cated_id: pdd.id, cated: pdd.name, categ: tmp3, gTotal: tmp3.sum{ |a| a[:i] }}

      end

      @data


    end
  end
end
