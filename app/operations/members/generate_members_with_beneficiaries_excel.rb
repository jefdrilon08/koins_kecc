module Members
  class GenerateMembersWithBeneficiariesExcel
    def initialize(members:, branch:)
      @members           = members
      @branch            = branch
      @p                 = Axlsx::Package.new
      @header_labels  = [
        "ID Number",
        "Name",
        "Status",
        "Insurance Status",
        "Branch",
        "Center",
        "Recognition Date",
        "Beneficiary Name",
        "Beneficiary DOB",
        "Beneficiary Age",
        "Relationship to Member",
        "Stat"
      ]
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          if @branch.present?
            sheet.add_row ["Members with beneficiary list from #{@branch.to_s}"]
          end

          # Headers
          sheet.add_row @header_labels

          @members.each do |member|
            member_row  = []
            member_row  <<  member.identification_number
            member_row  <<  member.full_name
            member_row  <<  member.status
            member_row  <<  member.insurance_status
            member_row  <<  member.branch.name
            member_row  <<  member.center.name
            member_row  <<  member.data['recognition_date']
            if member.beneficiaries.where(is_primary: true).count > 0
              member_row  <<  member.beneficiaries.where(is_primary: true).order("created_at DESC").first.full_name
              member_row  <<  member.beneficiaries.where(is_primary: true).order("created_at DESC").first.date_of_birth
              member_row  <<  member.beneficiaries.where(is_primary: true).order("created_at DESC").first.age
              member_row  <<  member.beneficiaries.where(is_primary: true).order("created_at DESC").first.relationship
              member_row  <<  "Primary"
            else
              member_row  <<  nil
              member_row  <<  nil
              member_row  <<  nil
              member_row  <<  nil
              member_row  <<  nil
            end

            sheet.add_row member_row
          
            if member.beneficiaries.where("is_primary IS NOT ?", true).count > 0
              dependent_row = []
              dependent_row  <<  member.identification_number
              dependent_row  <<  member.full_name
              dependent_row  <<  member.status
              dependent_row  <<  member.insurance_status
              dependent_row  <<  member.branch.name
              dependent_row  <<  member.center.name
              dependent_row  <<  member.data['recognition_date']
              dependent_row  <<  member.beneficiaries.where("is_primary IS NOT ?", true).first.full_name
              dependent_row  <<  member.beneficiaries.where("is_primary IS NOT ?", true).first.date_of_birth
              dependent_row  <<  member.beneficiaries.where("is_primary IS NOT ?", true).first.age
              dependent_row  <<  member.beneficiaries.where("is_primary IS NOT ?", true).first.relationship
              dependent_row  <<  "Secondary" 
            
              sheet.add_row dependent_row
            end
          end
        end
      end

      @p
    end
  end
end
