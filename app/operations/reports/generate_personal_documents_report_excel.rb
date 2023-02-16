module Reports
  class GeneratePersonalDocumentsReportExcel
    def initialize(start_date:, end_date:, branch:, insurance_status:)
      @end_date         = end_date
      @start_date       = start_date
      @branch           = branch
      @insurance_status = insurance_status

      if !@start_date.nil? &&  !@end_date.nil? && !@branch.nil?
        @members  = ReadOnlyMember.active_and_resigned.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch)
      end

      if @insurance_status.present?
        @members = @members.where(insurance_status: @insurance_status)
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
            "INSURANCE STATUS",
            "RECOGNITION DATE",
            "DATE RESIGNED",
            "DOB",
            "AGE",
            "BRANCH",
            "CENTER",
            "NO. OF DOCX",
            "ATTACHMENT FILES",
            "NAMES",
            "REMARKS"
          ], style: header

          @members.each_with_index do |member|

            member_row = []

            member_row << member.identification_number
            member_row << member.first_name.try(:upcase)
            member_row << member.middle_name.try(:upcase)
            member_row << member.last_name.try(:upcase)
            member_row << member.status
            member_row << member.insurance_status
            member_row << member.data['recognition_date']
            member_row << member.date_resigned
            member_row << member.try(:date_of_birth).try(:to_date)
            member_row << member.age
            member_row << member.branch.name
            member_row << member.center.name
            if member.attachment_files.count ==0
                member_row << '1'
                member_row << 'BLIPFORM'
            else
            member_row << member.attachment_files.count
            end

            if member.status == "resigned"
              sheet.add_row member_row, style: [ black_white, black_white, black_white, black_white, black_white, black_white, black_white_date, black_white_date, black_white, black_white, black_white, black_white ]
            elsif member.status == "active"
              sheet.add_row member_row, style: [ nil, nil, nil, nil, nil, nil, date_format_cell, date_format_cell, nil, nil, nil, nil, nil, nil, nil]
            end


            if member.attachment_files.count > 0
              member.attachment_files.each do |bc|
                file_name = bc.file_name
                bc = file_name.split('_')[0]
                bc_name = file_name.split('_')[1]
                bc_remarks = file_name.split('_')[2]

                sheet.add_row [ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, bc, bc_name, bc_remarks ]
              end
            end

          end
        end
      end

      @p
    end
  end
end

