module Members
  class GenerateRegistryOfMembers
    def initialize(branch:)
      
      @member = Member.select("*").where(status: "active",branch_id: branch.pluck(:id))
    
      @p = Axlsx::Package.new
    end
    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          sheet.add_row ["Branch","Membership Number","Name of Member","Center","Street","Barangay","City","Home Number","Mobile Number"] 
          @member.order("last_name").each do |m|
          
            center_name = Center.find(m.center_id).name
            branch_name = Branch.find(m.branch_id).name
            sheet.add_row [
                            branch_name,
                            m.identification_number,
                            m.full_name,
                            center_name,
                            m.data.with_indifferent_access[:address][:street],
                            m.data.with_indifferent_access[:address][:district],
                            m.data.with_indifferent_access[:address][:city],
                            m.home_number,
                            m.mobile_number
                          ] 
          end
        end
      end
      @p
    end
  end
end
