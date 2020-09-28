module Reports
  class GenerateKbenteExcelReport
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
     

      if @branch.present? && @start_date.present? && @end_date.present?
        @kbente   = Claim.where("data->>'date_approved' >= ? AND data->>'date_approved' <= ? AND branch_id = ? AND claim_type = ? AND status = ?", @start_date, @end_date, @branch, "K-BENTE", "approved").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @kbente   = Claim.where("data->>'date_approved' >= ? AND data->>'date_approved' <= ? AND claim_type = ? AND status = ?", @start_date, @end_date, "K-BENTE", "approved").order("created_at DESC")
      elsif @branch.present?
        @kbente   = Claim.where("branch_id = ? AND claim_type = ? AND status = ?", @branch, "K-BENTE", "approved").order("created_at DESC")
      else
        @kbente = Claim.where(claim_type: 'K-BENTE', status: "approved")
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
            "Date Prepared",
            "Cluster",
            "Branch",
            "Center",
            "Name of Member",
            "Date Approved",
            "Purpose",
            "Amount",
            "Name of Insured",
            "Name of Beneficiary",
            "Classification",
            "Date of Birth",
            "Date of Death",
            "Date Enrolled",
            "Date Expired",
            "Prepared by",
            "Status"
          ], style: header

          @kbente.each_with_index do |kbente|
              sheet.add_row [
                  kbente.date_prepared.try(:strftime, "%b %d, %Y"),
                  kbente.branch.cluster.name,
                  kbente.member.branch.name,
                  kbente.member.center.name,
                  kbente.member.full_name,
                  kbente.data["date_approved"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.data["purpose"],
                  kbente.data["amount"],
                  kbente.data["name_of_insured"],
                  kbente.data["name_of_beneficiary"],
                  kbente.data["classification"],
                  kbente.data["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.data["date_of_death"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.data["date_enrolled"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.data["date_expired"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.prepared_by,
                  kbente.status
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
