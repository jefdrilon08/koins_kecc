module Reports
  class GeneratePersonalDocumentsReportExcel
    def initialize(start_date:, end_date:, branch:)
      @end_date   = end_date
      @start_date = start_date
      @branch     = branch
      if !@start_date.nil? &&  !@end_date.nil? && !@branch.nil?
        @members  = Member.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch)
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
          black_white_date = wb.styles.add_style(:bg_color => "000000", :fg_color => "FFFFFF", :format_code => "dd-mm-yyyy", font_name: "Calibri")
          black_white = wb.styles.add_style(:bg_color => "000000", :fg_color => "FFFFFF", font_name: "Calibri")

          sheet.add_row [ 
            "ID NUMBER",
            "FIRST NAME",
            "MIDDLE NAME",
            "LAST NAME",
            "STATUS",
            "RECOGNITION DATE",
            "DOB",
            "AGE",
            "BRANCH",
            "CENTER",
            "NO. OF DOCX",
            "ATTACHMENT FILES"
          ], style: header

          @members.each_with_index do |member|

            member_row = []
            
            member_row << member.identification_number
            member_row << member.first_name.try(:upcase)
            member_row << member.middle_name.try(:upcase)
            member_row << member.last_name.try(:upcase)
            member_row << member.status
            member_row << member.data['recognition_date']
            member_row << member.try(:date_of_birth).try(:to_date)
            member_row << member.age
            member_row << member.branch.name
            member_row << member.center.name
            member_row << member.attachment_files.count
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%BLIP%").first.try(:file_name) 
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%BC%").first.try(:file_name) 
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%ID%").first.try(:file_name) 
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%MC%").first.try(:file_name)
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%COHA%").first.try(:file_name) 
            member_row << member.attachment_files.where("upper(file_name) LIKE ?", "%OTHER%").first.try(:file_name) 
            # member.attachment_files.order("file_name").each do |att|

              # if att.file_name == "BC" 
              #   member_row << att.file_name
              # elsif att.file_name == "BLIPFORM"
              #   member_row << att.file_name
              # elsif att.file_name == "COHABITATION"
              #   member_row << att.file_name
              # elsif att.file_name == "ID"
              #   member_row << att.file_name
              # elsif att.file_name == "MC"
              #   member_row << att.file_name
              # elsif att.file_name == "OTHERFILE"
              #   member_row << att.file_name
              # end
            # end

            if member.status == "resigned"
              sheet.add_row member_row, style: [ black_white, black_white, black_white, black_white,  black_white, black_white_date, black_white_date, black_white, black_white, black_white, black_white, black_white, black_white ]
            elsif member.status == "active"
              sheet.add_row member_row, style: [ nil, nil, nil, nil, nil, date_format_cell, date_format_cell, nil, nil, nil, nil, nil, nil, nil]
            end
          end
        end
      end

      @p
    end
  end
end
