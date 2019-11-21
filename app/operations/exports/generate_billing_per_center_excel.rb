module Exports
  class GenerateBillingPerCenterExcel
    def initialize(members:, center:)
      @members           = members
      @center            = center
      @date              = Date.today
      @p                 = Axlsx::Package.new
      
      @header_labels  = [
        "",
        "Member Name",
        "Week 1",
        "Week 2",
        "Week 3",
        "Week 4",
        "Week 5",
        "TOTAL"
      ]
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style alignment: {horizontal: :left}, b: true,  font_name: "Arial"
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Arial"
          left_bold_underline = wb.styles.add_style u: true, font_name: "Arial", alignment: { horizontal: :left }, b: true
          underline_cell = wb.styles.add_style u: true, font_name: "Arial"
          bold_center = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Arial"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Arial", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Arial"
          bold_center_border = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Arial", :border => { :style => :thin, :color => "FF000000" }
          bold_left_border = wb.styles.add_style alignment: { horizontal: :left }, b: true, font_name: "Arial", :border => { :style => :thin, :color => "FF000000" }
          left_border = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Arial", :border => { :style => :thin, :color => "FF000000" }
          center = wb.styles.add_style alignment: { horizontal: :center }, font_name: "Arial"

          sheet.add_row [ "", "For the month of:", @date.strftime('%B %Y') ], style: [ nil, header, left_bold_underline ]
          sheet.add_row [ "", "Members list from:", @center.to_s ], style: [ nil, header, left_bold_underline ]
          sheet.add_row [ "", "Center #:", ""], style: [ nil, header, left_bold_underline ]
          sheet.add_row [ "", "Center Meeting:", @center.meeting_day], style: [ nil, header, left_bold_underline ]
          sheet.add_row [""]


          sheet.add_row ["", "", "DATE", "DATE", "DATE", "DATE", "DATE"], style: [ default_cell, default_cell, default_cell, default_cell, default_cell, default_cell, default_cell ]
          sheet.add_row ["", "", @date.strftime("%m / ___ / %Y"), @date.strftime("%m / ___ / %Y"), @date.strftime("%m / ___ / %Y"), @date.strftime("%m / ___ / %Y"), @date.strftime("%m / ___ / %Y"), ""], style: [ bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border ]
          # Headers
          sheet.add_row @header_labels, style: [ bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border ]

          count = 1
          @members.each do |member|
            member_row  = []
            member_row  <<  count
            member_row  <<  member.full_name_middle_initial
            member_row  << ""
            member_row  << ""
            member_row  << ""
            member_row  << ""
            member_row  << ""
            member_row  << ""
            sheet.add_row member_row,  style: [ left_border, left_border, left_border, left_border, left_border, left_border, left_border, left_border ] 
            count = count + 1
          end
        
          sheet.add_row ["", "TOTAL", "", "", "", "", "", ""] , style: [ bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border, bold_center_border ]
          sheet.add_row [""]
          sheet.add_row ["", "AR#:", "_____________", "_____________", "_____________", "_____________", "_____________" ], style: [ nil, center, center, center, center, center, center ]
          sheet.add_row ["", "Date Check:", "_____________", "_____________", "_____________", "_____________", "_____________" ], style: [ nil, center, center, center, center, center, center ]
          sheet.add_row [""]
          sheet.add_row ["", "", "Remitted by:", "Remitted by:", "Remitted by:", "Remitted by:", "Remitted by:" ]
          sheet.add_row ["", "", "_____________", "_____________", "_____________", "_____________", "_____________" ], style: [ nil, nil, center, center, center, center, center ]
          sheet.add_row ["", "", "CDO", "CDO", "CDO", "CDO", "CDO" ], style: [ nil, nil, center, center, center, center, center ]
          
          sheet.column_widths 3, 30, 14, 14, 14, 14, 14, 10
        end
      end

      @p
    end
  end
end
