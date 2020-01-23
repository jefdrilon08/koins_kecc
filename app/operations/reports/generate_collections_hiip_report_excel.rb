module Reports
  class GenerateCollectionsHiipReportExcel
    def initialize(branch:, cluster:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @cluster = cluster
      @branch = branch

      if @cluster.present? && @branch == "--ALL--"
        @cluster_branch   = Branch.where(cluster_id: @cluster)
        @hiip_claim   = HiipClaim.where("date_posted >= ? AND date_posted <= ? AND branch_id IN (?)", @start_date, @end_date, @cluster_branch.ids)
      else
        @hiip_claim   = HiipClaim.where("date_posted >= ? AND date_posted <= ? AND branch_id IN (?)", @start_date, @end_date, @branch)
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
            "Policy Number",
            "Branch",
            "Center",
            "Effective Date",
            "Expiration Date",
            "Date Admitted",
            "Date Discharge",
            "Number of Days to be paid",
            "Date of Birth",
            "Age",
            "Reason of Confinement",
            "Diagnosis",
            "Payee",
            "Amount",
            "Balance"
          ], style: header

          @hiip_claim.each_with_index do |hiip_claim|
              sheet.add_row [
                  hiip_claim.member.full_name,
                  hiip_claim.policy_number,
                  hiip_claim.branch.name,
                  hiip_claim.center.name,
                  hiip_claim.effective_date_of_coverage.strftime("%b %d, %Y"),
                  hiip_claim.expiration_date_of_coverage.strftime("%b %d, %Y"),
                  hiip_claim.date_admitted.strftime("%b %d, %Y"),
                  hiip_claim.date_discharged.strftime("%b %d, %Y"),
                  hiip_claim.number_ofdays_tobepaid,
                  hiip_claim.date_of_birth.strftime("%b %d, %Y"),
                  hiip_claim.age,
                  hiip_claim.reason_of_confinement,
                  hiip_claim.diagnosis,
                  hiip_claim.check_payee,
                  hiip_claim.amount,
                  hiip_claim.balance,
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
