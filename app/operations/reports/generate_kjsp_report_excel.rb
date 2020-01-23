module Reports
  class GenerateKjspReportExcel
    def initialize(branch:, cluster:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @cluster = cluster
      @branch = branch
     

      if @cluster.present? && @branch == "--ALL--"
        @cluster_branch   = Branch.where(cluster_id: @cluster)
        @kjsp_claim  = KjspClaim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id IN (?)", @start_date, @end_date, @cluster_branch.ids)
      else
        @kjsp_claim   = KjspClaim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id IN (?)", @start_date, @end_date, @branch)
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
            "Name of Member",
            "Branch",
            "Center",
            "Date Prepared",
            "Name of Scholar",
            "Payee",
            "Amount",
            "Name of School",
            "School Year",
            "Sem",
            "KJSP Type",
            "Final Grade",
            "Remarks",
            "Classification"
          ], style: header

          @kjsp_claim.each_with_index do |kjsp_claim|
              sheet.add_row [
                  kjsp_claim.member.full_name,
                  kjsp_claim.branch.name,
                  kjsp_claim.center.name,
                  kjsp_claim.date_prepared.strftime("%b %d, %Y"),
                  kjsp_claim.name_of_kjsp_beneficiary,
                  kjsp_claim.payee,
                  kjsp_claim.amount,
                  kjsp_claim.name_of_school,
                  kjsp_claim.school_year,
                  kjsp_claim.sem,
                  kjsp_claim.kjsp_type,
                  kjsp_claim.final_grade,
                  kjsp_claim.remarks,
                  kjsp_claim.classification
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
