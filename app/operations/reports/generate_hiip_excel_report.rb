module Reports
  class GenerateHiipExcelReport
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch

      if @branch.present? && @start_date.present? && @end_date.present?
        @hiip   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND claim_type = ? AND status = ?", @start_date, @end_date, @branch, "HIIP", "approved").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @hiip   = Claim.where("date_prepared >= ? AND date_prepared <= ? AND claim_type = ? AND status = ?", @start_date, @end_date, "HIIP", "approved").order("created_at DESC")
      elsif @branch.present?
        @hiip   = Claim.where("branch_id = ? AND claim_type = ? AND status = ?", @branch, "HIIP", "approved").order("created_at DESC")
      else
        @hiip = Claim.where(claim_type: 'HIIP', status: "approved")
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
            "Gender",
            "Certificate Number",
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
            "Balance",
            "Prepared by",
            "Status"
          ], style: header

          @hiip.each_with_index do |hiip|
              sheet.add_row [
                  hiip.created_at.try(:strftime, "%b %d, %Y"),
                  hiip.created_at.strftime("%I:%M%P"),
                  hiip.date_prepared.try(:strftime, "%b %d, %Y"),
                  hiip.branch.cluster.name,
                  hiip.branch.name,
                  hiip.center.name,
                  hiip.member.full_name,
                  hiip.member.age,
                  hiip.member.gender,
                  hiip.data["certificate_number"],
                  hiip.data["effective_date_of_coverage"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  hiip.data["expiration_date_of_coverage"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  hiip.data["date_admitted"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  hiip.data["date_discharged"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  hiip.data["number_of_days_tobepaid"],
                  hiip.data["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  hiip.data["age"],
                  hiip.data["reason_of_confinement"],
                  hiip.data["diagnosis"],
                  hiip.data["name_of_claimant"],
                  hiip.data["amount"],
                  hiip.data["balance"],
                  hiip.prepared_by,
                  hiip.status
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
