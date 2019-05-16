module Members
  class GenerateMemberDependentsReportExcel
    def initialize(members:)
      @members  = members
      @p        = Axlsx::Package.new
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          sheet.add_row [
            "ID Number", 
            "Last Name", 
            "First Name", 
            "Middle Name",
            "",
            "Dependent Last Name",
            "Depdendent First Name",
            "Depdendent Middle Name",
            "Birthday",
            "Age"
          ], style: header

          @members.each do |member|
            member.legal_dependents.order("date_of_birth ASC").each_with_index do |legal_dependent, i|
              if i == 0
                sheet.add_row [
                  member.identification_number,
                  member.last_name,
                  member.first_name,
                  member.middle_name,
                  "",
                  legal_dependent.last_name,
                  legal_dependent.first_name,
                  legal_dependent.middle_name,
                  legal_dependent.date_of_birth,
                  legal_dependent.age
                ]
              else
                sheet.add_row [
                  "",
                  "",
                  "",
                  "",
                  "",
                  legal_dependent.last_name,
                  legal_dependent.first_name,
                  legal_dependent.middle_name,
                  legal_dependent.date_of_birth,
                  legal_dependent.age
                ]
              end
            end
          end
        end
      end

      @p
    end
  end
end
