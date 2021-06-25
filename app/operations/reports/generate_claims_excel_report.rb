module Reports
  class GenerateClaimsExcelReport
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
     

      if @branch.present? && @start_date.present? && @end_date.present?
        @claims   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("created_at DESC, status ASC")
      elsif @start_date.present? && @end_date.present?
        @claims   = Claim.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date).order("created_at DESC, status ASC")
      elsif @branch.present?
        @claims   = Claim.where("branch_id = ?", @branch).order("created_at DESC, status ASC")
      else
        @claims   = Claim.all.order("created_at DESC, status ASC")
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
            "Claim Type",
            "Prepared by",
            "Status"
          ], style: header

          @claims.each_with_index do |claim|
            sheet.add_row [
                claim.created_at.try(:strftime, "%b %d, %Y"),
                claim.created_at.strftime("%I:%M%P"),
                claim.date_prepared.try(:strftime, "%b %d, %Y"),
                claim.branch.cluster.name,
                claim.branch.name,
                claim.member.center.name,
                claim.member.full_name,
                claim.claim_type,
                claim.prepared_by,
                claim.status
              ], style: [nil]             
            end
          end
        end
      @p
    end
  end
end
