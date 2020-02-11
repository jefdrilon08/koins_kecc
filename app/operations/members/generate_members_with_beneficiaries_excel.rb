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
        "Beneficiary Age",
        "Is Primary"
      ]
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          if @branch.present?
            sheet.add_row ["Members list from #{@branch.to_s}"]
          end

          # Headers
          sheet.add_row @header_labels

          @members.each do |member|
            if member.beneficiaries.count > 0
              primary_bene = []
              secondary_bene = []

              member.beneficiaries.each do |bene|  
                if bene.is_primary
                  primary_bene << bene
                else
                  secondary_bene << bene
                end
              end
            end

            member_row  = []
            member_row  <<  member.identification_number
            member_row  <<  member.full_name
            member_row  <<  member.status
            member_row  <<  member.insurance_status
            member_row  <<  member.branch.name
            member_row  <<  member.center.name
            member_row  <<  member.data['recognition_date']
            if member.beneficiaries.where(is_primary: true).count > 0
              member_row  <<  member.beneficiaries.where(is_primary: true).first.full_name
              member_row  <<  member.beneficiaries.where(is_primary: true).first.age
              member_row  <<  member.beneficiaries.where(is_primary: true).first.is_primary
            else
              member_row  <<  ""
              member_row  <<  ""
              member_row  <<  ""
            end

            sheet.add_row member_row
          end
        end
      end

      @p
    end
  end
end
