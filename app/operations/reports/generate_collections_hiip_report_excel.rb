module Reports
  class GenerateCollectionsHiipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch


      #@members  = Member.pure_active.where("previous_mii_member_since <= ? AND insurance_status != ? AND member_type != ? and branch_id = ?", @end_date, "dormant", "GK", @branch).order("identification_number ASC")
      @members  = Member.where("data ->>'recognition_date' <= ? AND branch_id = ?", @end_date, @branch).order("identification_number ASC")
 
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
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [ 
            "Number",
            "Name of Member",
          ], style: header

           @members.each_with_index do |member, index|
            @active_loans = []
            if index == 0
              sheet.add_row [
                  "",
                  member.full_name_titleize,
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              else
                sheet.add_row [
                  "",
                  member.full_name_titleize,
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              end
            end
          end
        end
      @p
    end
  end
end
