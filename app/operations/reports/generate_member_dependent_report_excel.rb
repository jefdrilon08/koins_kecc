module Reports
  class GenerateMemberDependentReportExcel
    def initialize(start_date:, end_date:, branch:)
      @end_date   = end_date
      @start_date = start_date
      @branch     = branch
      if !@start_date.nil? &&  !@end_date.nil? && !@branch.nil?
        if Settings.activate_microinsurance
          @members  = Member.active.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status != ? AND branch_id = ? AND member_type = ?", @start_date, @end_date, "dormant", @branch, "Regular")
        else  
          @members  = Member.active.where("data ->>'recognition_date' >= ? AND data ->>'recognition_date' <= ? AND insurance_status = ? AND branch_id = ? AND member_type = ?", @start_date, @end_date, "inforce", @branch, "Regular").order("center_id ASC")
        end
      end

      @p        = Axlsx::Package.new
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          label_cell = wb.styles.add_style b: true, font_name: "Calibri"
          currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "dd-mm-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [ 
            "NO",
            "ID NUMBER",
            "RECOGNITION DATE",
            "LAST NAME",
            "FIRST NAME",
            "MI",
            "REL",
            "CIVIL STATUS",
            "GENDER",
            "DOB",
            "AGE",
            "BRACH",
            "CENTER"
          ], style: header

          @members.each_with_index do |member, index|

            if member.civil_status.present?
              if member.civil_status == "Single" || member.civil_status.try(:upcase) == "SINGLE"
                civil_status = "SINGLE"
              elsif member.civil_status == "May Kinakasama"
                civil_status = "WITH PARTNER"
              elsif member.civil_status == "Kasal" || member.civil_status.try(:upcase) == "MARRIED"
                civil_status = "MARRIED"
              elsif member.civil_status == "Hiwalay" || member.civil_status.try(:upcase) == "SEPARATED"
                civil_status = "SEPARATED"
              elsif member.civil_status == "Biyudo/a" || member.civil_status.try(:upcase) == "WIDOWED"
                civil_status = "WIDOWED"
              end    
            end

            if member.gender.present?
              if member.gender == "Female"
                gender = "FEMALE"
                gender_spouse = "MALE"
              elsif member.gender == "Male"
                gender = "MALE"
                gender_spouse = "FEMALE"
              else
                gender = "OTHERS"
                gender_spouse = "OTHERS"
              end
            end
          

            if member.data['spouse']['first_name'].present? 
              if member.civil_status == "Kasal" || member.civil_status.try(:upcase) == "MARRIED" || member.civil_status == "May Kinakasama"
                if member.spouse_age.to_i < 65
                  dependent_last_name = member.data['spouse']['last_name'].upcase
                  dependent_first_name = member.data['spouse']['first_name'].upcase
                  dependent_middle_name = member.data['spouse']['middle_name'].upcase
                  dependent_date_of_birth = member.data['spouse']['date_of_birth'].try(:upcase) 
                  dependent_civil_status = civil_status
                  dependent_gender = gender_spouse
                  dependent_relationship_to_member = "SPOUSE"
                  dependent_age = member.spouse_age
                else
                  if member.legal_dependents.count > 0
                    valid_dependents = []
                    
                  member.legal_dependents.order("date_of_birth ASC").each do |dependent|  
                      if dependent.age <= 20 
                        valid_dependents << dependent
                      end
                    end
                
                    if valid_dependents.count > 0
                      dependent_last_name = valid_dependents.first.last_name.upcase
                      dependent_first_name = valid_dependents.first.first_name.upcase
                      dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "SINGLE"
                      dependent_gender = "MALE"
                      dependent_relationship_to_member = "CHILD"
                      dependent_age = valid_dependents.first.age
                    else
                      dependent_last_name = ""
                      dependent_first_name = ""
                      dependent_middle_name = ""
                      dependent_date_of_birth = ""
                      dependent_civil_status = ""
                      dependent_gender = ""
                      dependent_relationship_to_member = ""
                      dependent_age = "" 
                    end
                  end
                end
              elsif member.civil_status == "Single" || member.civil_status.try(:upcase) == "SINGLE"
                if member.legal_dependents.count > 0    
                  valid_dependents = []

                 member.legal_dependents.order("date_of_birth ASC").each do |dependent|
                    if dependent.age >= 60 && dependent.age < 65 
                      valid_dependents << dependent
                    elsif dependent.age <= 20
                      valid_dependents << dependent  
                    end
                  end

                  if valid_dependents.count > 0
                    if valid_dependents.first.age > 60 
                      dependent_last_name = valid_dependents.first.last_name.upcase
                      dependent_first_name = valid_dependents.first.first_name.upcase
                      dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "MARRIED"
                      dependent_gender = "FEMALE"
                      dependent_relationship_to_member = "PARENT"
                      dependent_age = valid_dependents.first.age
                    else  
                      dependent_last_name = valid_dependents.first.last_name.upcase
                      dependent_first_name = valid_dependents.first.first_name.upcase
                      dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "SINGLE"
                      dependent_gender = "MALE"
                      dependent_relationship_to_member = "CHILD"
                      dependent_age = valid_dependents.first.age
                    end
                  else
                    dependent_last_name = ""
                    dependent_first_name = ""
                    dependent_middle_name = ""
                    dependent_date_of_birth = ""
                    dependent_civil_status = ""
                    dependent_gender = ""
                    dependent_relationship_to_member = ""
                    dependent_age = "" 
                  end                 
                end
              else
                if member.legal_dependents.count > 0
                  valid_dependents = []
                  
                  member.legal_dependents.order("date_of_birth ASC").each do |dependent|  
                    if dependent.age <= 20
                      valid_dependents << dependent
                    end
                  end
              
                  if valid_dependents.count > 0
                    dependent_last_name = valid_dependents.first.last_name.upcase
                    dependent_first_name = valid_dependents.first.first_name.upcase
                    dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                    dependent_date_of_birth = valid_dependents.first.date_of_birth
                    dependent_civil_status = "SINGLE"
                    dependent_gender = "MALE"
                    dependent_relationship_to_member = "CHILD"
                    dependent_age = valid_dependents.first.age
                  else
                    dependent_last_name = ""
                    dependent_first_name = ""
                    dependent_middle_name = ""
                    dependent_date_of_birth = ""
                    dependent_civil_status = ""
                    dependent_gender = ""
                    dependent_relationship_to_member = ""
                    dependent_age = "" 
                  end
                end  
              end
            elsif member.legal_dependents.count > 0
              valid_dependents = []
              
              if member.civil_status == "Kasal" || member.civil_status.try(:upcase) == "MARRIED" || member.civil_status == "MAY Kinakasama" 
        
                member.legal_dependents.order("date_of_birth ASC").each do |dependent|  
                  if dependent.age <= 20 
                    valid_dependents << dependent
                  end
                end
                
                if valid_dependents.count > 0
                  dependent_last_name = valid_dependents.first.last_name.upcase
                  dependent_first_name = valid_dependents.first.first_name.upcase
                  dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                  dependent_date_of_birth = valid_dependents.first.date_of_birth
                  dependent_civil_status = "SINGLE"
                  dependent_gender = "MALE"
                  dependent_relationship_to_member = "CHILD"
                  dependent_age = valid_dependents.first.age
                else
                  dependent_last_name = ""
                  dependent_first_name = ""
                  dependent_middle_name = ""
                  dependent_date_of_birth = ""
                  dependent_civil_status = ""
                  dependent_gender = ""
                  dependent_relationship_to_member = ""
                  dependent_age = "" 
                end
              elsif member.civil_status == "Single" || member.civil_status.try(:upcase) == "SINGLE"
                if member.legal_dependents.count > 0    
                  valid_dependents = []

                  member.legal_dependents.order("date_of_birth ASC").each do |dependent|
                    if dependent.age >= 60 && dependent.age < 65
                      valid_dependents << dependent
                    elsif dependent.age <= 20
                        valid_dependents << dependent  
                    end
                  end

                  if valid_dependents.count > 0
                    if valid_dependents.first.age > 60 
                      dependent_last_name = valid_dependents.first.last_name.upcase
                      dependent_first_name = valid_dependents.first.first_name.upcase
                      dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "MARRIED"
                      dependent_gender = "FEMALE"
                      dependent_relationship_to_member = "PARENT"
                      dependent_age = valid_dependents.first.age
                    else  
                      dependent_last_name = valid_dependents.first.last_name.upcase
                      dependent_first_name = valid_dependents.first.first_name.upcase
                      dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                      dependent_date_of_birth = valid_dependents.first.date_of_birth
                      dependent_civil_status = "SINGLE"
                      dependent_gender = "MALE"
                      dependent_relationship_to_member = "CHILD"
                      dependent_age = valid_dependents.first.age
                    end
                  else
                    dependent_last_name = ""
                    dependent_first_name = ""
                    dependent_middle_name = ""
                    dependent_date_of_birth = ""
                    dependent_civil_status = ""
                    dependent_gender = ""
                    dependent_relationship_to_member = ""
                    dependent_age = "" 
                  end                 
                end
              else
                if member.legal_dependents.count > 0
                  valid_dependents = []
                  
                  member.legal_dependents.order("date_of_birth ASC").each do |dependent|  
                      if dependent.age <= 20 
                        valid_dependents << dependent
                      end
                    end
              
              
                  if valid_dependents.count > 0
                    dependent_last_name = valid_dependents.first.last_name.upcase
                    dependent_first_name = valid_dependents.first.first_name.upcase
                    dependent_middle_name = valid_dependents.first.middle_name[0].try(:upcase)
                    dependent_date_of_birth = valid_dependents.first.date_of_birth
                    dependent_civil_status = "SINGLE"
                    dependent_gender = "MALE"
                    dependent_relationship_to_member = "CHILD"
                    dependent_age = valid_dependents.first.age
                  else
                    dependent_last_name = ""
                    dependent_first_name = ""
                    dependent_middle_name = ""
                    dependent_date_of_birth = ""
                    dependent_civil_status = ""
                    dependent_gender = ""
                    dependent_relationship_to_member = ""
                    dependent_age = "" 
                  end
                end  
              end
            else
              dependent_last_name = ""
              dependent_first_name = ""
              dependent_middle_name = ""
              dependent_date_of_birth = ""
              dependent_civil_status = ""
              dependent_gender = ""
              dependent_relationship_to_member = ""
              dependent_age = "" 
            end

            if index == 0
              sheet.add_row [
                  "",
                  member.identification_number,
                  member.recognition_date,
                  member.last_name.upcase,
                  member.first_name.upcase,
                  member.middle_name[0].try(:upcase),
                  "PRINCIPAL",
                  civil_status,
                  gender,
                  member.try(:date_of_birth).try(:to_date),
                  member.age,
                  member.branch,
                  member.center.to_s
                ], style: [nil, nil, date_format_cell, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, nil]
             
                sheet.add_row [
                    "",
                    "",
                    "",
                    dependent_last_name,
                    dependent_first_name,
                    dependent_middle_name,
                    dependent_relationship_to_member,
                    dependent_civil_status,
                    dependent_gender,
                    dependent_date_of_birth,
                    dependent_age,
                    member.branch,
                    member.center.to_s,
                    ""
                  ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, nil]
    
            else
              sheet.add_row [
                  "",
                  member.identification_number,
                  member.recognition_date,
                  member.last_name.upcase,
                  member.first_name.upcase,
                  member.middle_name[0].try(:upcase),
                  "PRINCIPAL",
                  civil_status,
                  gender,
                  member.try(:date_of_birth).try(:to_date),
                  member.age,
                  member.branch,
                  member.center.to_s
                ], style: [nil, nil, date_format_cell, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, nil]
              
                #if dependent_first_name.present?  
                  sheet.add_row [
                      "",
                      "",
                      "",
                      dependent_last_name,
                      dependent_first_name,
                      dependent_middle_name,
                      dependent_relationship_to_member,
                      dependent_civil_status,
                      dependent_gender,
                      dependent_date_of_birth,
                      dependent_age,
                      member.branch,
                      member.center.to_s,
                    ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, nil]
                # else
                #    sheet.add_row [
                #       "",
                #       "",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #       "N/A",
                #     ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil]  
                # end
            end
          end
        end
      end

      @p
    end
  end
end
