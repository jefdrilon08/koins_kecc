module Reports
  class GenerateCollectionsHiipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch

      if @branch.present? && @start_date.present? && @end_date.present?
        @hiip   = Claim.where("date_prepared >= ? AND date_requested <= ? AND branch_id = ? AND claim_type = ?", @start_date, @end_date, @branch, "HIIP").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @hiip   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND claim_type = ?", @start_date, @end_date, "HIIP").order("created_at DESC")
      elsif @branch.present?
        @hiip   = Claim.where("branch_id = ? AND claim_type = ?", @branch, "HIIP").order("created_at DESC")
      else
        @hiip = Claim.where(claim_type: 'HIIP')
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
            "Certificate Number",
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

          @hiip.each_with_index do |hiip|
              sheet.add_row [
                  hiip.member.full_name,
                  hiip.data["certificate_number"],
                  hiip.member.branch.name,
                  hiip.member.center.name,
                  hiip.data["effective_date_of_coverage"],
                  hiip.data["expiration_date_of_coverage"],
                  hiip.data["date_admitted"],
                  hiip.data["date_discharged"],
                  hiip.data["number_of_days_tobepaid"],
                  hiip.data["date_of_birth"],
                  hiip.data["age"],
                  hiip.data["reason_of_confinement"],
                  hiip.data["diagnosis"],
                  hiip.data["name_of_claimant"],
                  hiip.data["amount"],
                  hiip.data["balance"]
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
