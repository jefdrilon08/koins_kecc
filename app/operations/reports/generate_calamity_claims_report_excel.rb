module Reports
  class GenerateCalamityClaimsReportExcel
    def initialize(branch:, cluster:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @cluster = cluster
      @branch = branch
     

      if @cluster.present? && @branch == "--ALL--"
        @cluster_branch   = Branch.where(cluster_id: @cluster)
        @calamity_claim   = CalamityClaim.where("date_requested >= ? AND date_requested <= ? AND branch_id IN (?)", @start_date, @end_date, @cluster_branch.ids)
      else
        @calamity_claim   = CalamityClaim.where("date_requested >= ? AND date_requested <= ? AND branch_id IN (?)", @start_date, @end_date, @branch)
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
            "Date Requested",
            "Purpose",
            "Type of Calamity",
            "Amount",
            "Date of Event",
            "Date of Approved",
            "Date of Notification",
            "Payee",
            "Name of Beneficiary"
          ], style: header

          @calamity_claim.each_with_index do |calamity_claim|
              sheet.add_row [
                  calamity_claim.member.full_name,
                  calamity_claim.branch.name,
                  calamity_claim.center.name,
                  calamity_claim.date_requested.strftime("%b %d, %Y"),
                  calamity_claim.purpose,
                  calamity_claim.type_of_calamity,
                  calamity_claim.amount,
                  calamity_claim.date_of_event.strftime("%b %d, %Y"),
                  calamity_claim.date_approved.strftime("%b %d, %Y"),
                  calamity_claim.date_of_notification.strftime("%b %d, %Y"),
                  calamity_claim.name_of_payee,
                  calamity_claim.name_of_beneficiary
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
