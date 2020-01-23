module Reports
  class GenerateKbenteReportExcel
    def initialize(branch:, cluster:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @cluster = cluster
      @branch = branch
     

      if @cluster.present? && @branch == "--ALL--"
        @cluster_branch   = Branch.where(cluster_id: @cluster)
        @kbente_claim  = KbenteClaim.where("date_reported >= ? AND date_reported <= ? AND branch_id IN (?)", @start_date, @end_date, @cluster_branch.ids)
      else
        @kbente_claim   = KbenteClaim.where("date_reported >= ? AND date_reported <= ? AND branch_id IN (?)", @start_date, @end_date, @branch)
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
            "Date Emailed",
            "Date Reported",
            "Date Approved",
            "Date Requested",
            "Purpose",
            "Amount",
            "Name of Insured",
            "Name of Beneficiary",
            "Classification",
            "Date of Death"
          ], style: header

          @kbente_claim.each_with_index do |kbente_claim|
              sheet.add_row [
                  kbente_claim.member.full_name,
                  kbente_claim.branch.name,
                  kbente_claim.center.name,
                  kbente_claim.date_emailed.strftime("%b %d, %Y"),
                  kbente_claim.date_reported.strftime("%b %d, %Y"),
                  kbente_claim.date_approved.strftime("%b %d, %Y"),
                  kbente_claim.date_requested.strftime("%b %d, %Y"),
                  kbente_claim.purpose,
                  kbente_claim.amount,
                  kbente_claim.name_of_insured,
                  kbente_claim.name_of_beneficiary,
                  kbente_claim.classification,
                  kbente_claim.date_of_death.strftime("%b %d, %Y")
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
