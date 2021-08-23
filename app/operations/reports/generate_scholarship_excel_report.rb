module Reports
  class GenerateScholarshipExcelReport
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
     

      if @branch.present? && @start_date.present? && @end_date.present?
        @scholarship   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND claim_type = ? AND status = ?", @start_date, @end_date, @branch, "KUYA JUN SCHOLARSHIP PROGRAM", "approved").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @scholarship   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND claim_type = ? AND status = ?", @start_date, @end_date, "KUYA JUN SCHOLARSHIP PROGRAM", "approved").order("created_at DESC")
      elsif @branch.present?
        @scholarship   = Claim.where("branch_id = ? AND claim_type = ? AND status = ?", @branch, "KUYA JUN SCHOLARSHIP PROGRAM", "approved").order("created_at DESC")
      else
        @scholarship = Claim.where(claim_type: 'KUYA JUN SCHOLARSHIP PROGRAM', status: "approved")
      end  

      @p          = Axlsx::Package.new
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
            "Date Encoded",
            "Time Encoded",
            "Date Prepared",
            "Cluster",
            "Branch",
            "Center",
            "Name of Member",
            "Age",
            "Name of Scholar",
            "Payee",
            "Amount",
            "Name of School",
            "School Year",
            "Sem",
            "Scholarship Type",
            "Final Grade",
            "Classification",
            "Course",
            "Prepared by",
            "Status"
          ], style: header

          @scholarship.each_with_index do |scholarship|
              sheet.add_row [
                  scholarship.created_at.try(:strftime, "%b %d, %Y"),
                  scholarship.created_at.strftime("%I:%M%P"),
                  scholarship.date_prepared.try(:strftime, "%b %d, %Y"),
                  scholarship.branch.cluster.name,
                  scholarship.branch.name,
                  scholarship.member.center.name,
                  scholarship.member.full_name,
                  scholarship.member.age,
                  scholarship.data["name_of_beneficiary"],
                  scholarship.data["payee"],
                  scholarship.data["amount"],
                  scholarship.data["name_of_school"],
                  scholarship.data["school_year"],
                  scholarship.data["sem"],
                  scholarship.data["scholarship_type"],
                  scholarship.data["final_grade"],
                  scholarship.data["classification"],
                  scholarship.data["course"],
                  scholarship.prepared_by,
                  scholarship.status
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
