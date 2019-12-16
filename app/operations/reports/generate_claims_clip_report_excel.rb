module Reports
  class GenerateClaimsClipReportExcel
    def initialize(branch:, type_of_loan:, start_date:, end_date:)
      @type_of_loan = type_of_loan
      @branch = branch
      @start_date = start_date
      @end_date = end_date

      if @branch.present? && @type_of_loan.present? && @start_date.present? && @end_date.present?
        @clip_claims = ClipClaim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND type_of_loan = ?", @start_date, @end_date, @branch, @type_of_loan).order("date_prepared DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present?
        @clip_claims = ClipClaim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("date_prepared DESC")
      elsif @type_of_loan.present? && @start_date.present? && @end_date.present?
        @clip_claims = ClipClaim.where("date_prepared >= ? AND date_prepared <= ? AND type_of_loan = ?", @start_date, @end_date, @type_of_loan).order("date_prepared DESC")
      elsif @start_date.present? && @end_date.present?
        @clip_claims = ClipClaim.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date).order("date_prepared DESC")
      else
        @clip_claims = ClipClaim.all
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
            "CLAIMS REPORT (CLIP) #{@start_date} #{@end_date} #{@branch} #{@type_of_loan}"
            ],style: header
          
          sheet.add_row []
          
          sheet.add_row [ 
            "Date Entered",
            "Creditors Name",
            "Branch",
            "Type of Insurance Policy",
            "Debtors Name (Member)",
            "Beneficiary",
            "CLIP Policy Number",
            "Date of Birth",
            "Age",
            "Sex",
            "Date of Death",
            "Cause of Death",
            "Effective Date of Coverage",
            "Expiration Date of Coverage",
            "Amount of Loan",
            "Terms of Loan (Weeks)",
            "Amount Payable to Beneficiary (Paid Amount)",
            "Amount Payable to Creditor (Balance)",
            "Prepared by:"
          ], style: header

          @clip_claims.each do |clip_claim|
            sheet.add_row [
              clip_claim.date_prepared,
              clip_claim.creditors_name,
              clip_claim.branch.name,
              "CLIP",
              clip_claim.member.full_name,
              clip_claim.beneficiary,
              clip_claim.policy_number,
              clip_claim.date_of_birth,
              clip_claim.age,
              clip_claim.gender,
              clip_claim.date_of_death,
              clip_claim.cause_of_death,
              clip_claim.effective_date_of_coverage,
              clip_claim.expiration_date_of_coverage,
              clip_claim.amount_of_loan,
              clip_claim.terms,
              clip_claim.amount_payable_to_beneficiary,
              clip_claim.amount_payable_to_creditor,
              clip_claim.prepared_by
            ], style: [date_format_cell, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, date_format_cell, nil, date_format_cell, date_format_cell, currency_cell_right, nil, currency_cell_right, currency_cell_right, nil]

            @total_amount_of_loan = @total_amount_of_loan + clip_claim.amount_of_loan
            @total_amount_payable_to_creditor = @total_amount_payable_to_creditor + clip_claim.amount_payable_to_creditor
            @total_amount_payable_to_beneficiary = @total_amount_payable_to_beneficiary + clip_claim.amount_payable_to_beneficiary
          end

          sheet.add_row [
            "TOTAL",
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
            @total_amount_of_loan,
            "",
            @total_amount_payable_to_beneficiary,
            @total_amount_payable_to_creditor,
            ""
            ], style: [header_cells, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, currency_cell_right_bold, nil, currency_cell_right_bold, currency_cell_right_bold, nil]

        end
      end
      @p
    end
  end
end
