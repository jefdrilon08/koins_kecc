module Reports
  class GenerateMemberProjectType
    def initialize(branch: )
      @branch = branch
      @data = {}
      @data[:list] = []
      @project_type_category = ProjectTypeCategory.all
    end

    def execute!
      @project_type_category.each do |ptc|
        tmp = {}
        tmp[:category_name] = ptc.name
        tmp[:list] = []
        project_type = ProjectType.where(project_type_category_id: ptc.id)
        project_type.each do |pt|
          tmpDetails = {}
          tmpDetails[:type_name] = pt.name
          tmpDetails[:loan_details] = []
          loan_details = Loan.where(status: "active", 
                                    loan_product_id: "4e517b79-5ee7-48f3-92ad-b6fb1a3c0a00", 
                                    branch_id: @branch,
                                    project_type_id: pt.id
                                  )
          tmpDetails[:loan_detail_count] = loan_details.count

          loan_details.each do |ld|
            tmpLoanDetails = {}

            tmpLoanDetails[:member_name] =  ld.member.full_name
            tmpLoanDetails[:principal] = ld.principal

            tmpDetails[:loan_details] << tmpLoanDetails 

          end

            tmpDetails[:total_principal] = tmpDetails[:loan_details].sum{ |x| x[:principal] .to_i}
            tmp[:list] << tmpDetails
        end

        tmp[:category_count] = tmp[:list].sum{ |x| x[:loan_detail_count].to_i }
        
        @data[:list] << tmp
        
      end
    
      @data
      
    



    end
  end

end
