module Reports
  class GenerateClipExcelReport
    def initialize(branch:, start_date:, end_date:)
      @branch = branch
      @start_date = start_date
      @end_date = end_date

      if @branch.present? && @start_date.present? && @end_date.present?
        @clip = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND claim_type = ? AND status = ? ", @start_date, @end_date, @branch, "CLIP", "approved").order("date_prepared DESC")
      elsif @start_date.present? && @end_date.present?
        @clip = Claim.where("date_prepared >= ? AND date_prepared <= ? AND claim_type = ? AND status = ?", @start_date, @end_date, "CLIP", "approved").order("date_prepared DESC")
      elsif @branch.present?
        @clip = Claim.where("branch_id = ? AND claim_type = ? AND status = ?", @branch, "CLIP", "approved").order("date_prepared DESC")
      else
        @clip = Claim.where(claim_type: "CLIP", status: "approved")
      end

      @p        = Axlsx::Package.new

      @total_amount_of_loan = 0.00
      @total_amount_payable_to_beneficiary = 0.00
      @total_amount_payable_to_creditor = 0.00
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell = wb.styles.add_style alignment: { horiontal: :center }, b: true, font_name: "Calibri"
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
            "Creditors Name",
            "Type of Insurance Policy",
            "Debtors Name (Member)",
            "Beneficiary",
            "Policy Number",
            "Date of Birth",
            "Age",
            "Sex",
            "Type of Loan",
            "Date of Death",
            "Cause of Death",
            "Effective Date of Coverage",
            "Expiration Date of Coverage",
            "Amount of Loan",
            "Terms of Loan (Weeks)",
            "Amount Payable to Beneficiary (Paid Amount)",
            "Amount Payable to Creditor (Balance)",
            "Prepared by",
            "Status"
          ], style: header

          @clip.each do |clip|
            sheet.add_row [
              clip.created_at.try(:strftime, "%b %d, %Y"),
              clip.created_at.strftime("%I:%M%P"),
              clip.date_prepared.try(:strftime, "%b %d, %Y"),
              clip.branch.cluster.name,
              clip.branch.name,
              clip.data["creditors_name"],
              "CLIP",
              clip.member.full_name,
              clip.data["beneficiary"],
              clip.data["policy_number"],
              clip.data["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
              clip.data["age"],
              clip.data["gender"],
              clip.data["type_of_loan"],
              clip.data["date_of_death"].try(:to_date).try(:strftime, "%b %d, %Y"),
              clip.data["cause_of_death"],
              clip.data["effective_date_of_coverage"].try(:to_date).try(:strftime, "%b %d, %Y"),
              clip.data["expiration_date_of_coverage"].try(:to_date).try(:strftime, "%b %d, %Y"),
              clip.data["amount_of_loan"],
              clip.data["terms"],
              clip.data["amount_payable_to_beneficiary"],
              clip.data["amount_payable_to_creditor"],
              clip.prepared_by,
              clip.status
            ], style: [nil]

            @total_amount_of_loan = @total_amount_of_loan + clip.data["amount_of_loan"].to_i
            @total_amount_payable_to_creditor = @total_amount_payable_to_creditor + clip.data["amount_payable_to_creditor"].to_i
            @total_amount_payable_to_beneficiary = @total_amount_payable_to_beneficiary + clip.data["amount_payable_to_beneficiary"].to_i
          end

          sheet.add_row [
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
            "",
            "",
            "",
            "",
            "TOTAL",
            "",
            @total_amount_of_loan,
            "",
            @total_amount_payable_to_beneficiary,
            @total_amount_payable_to_creditor,
            "",
            ""
            ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, header_cells, nil, currency_cell_right_bold, nil, currency_cell_right_bold, currency_cell_right_bold, nil, nil]

        end
      end
      @p
    end
  end
end
