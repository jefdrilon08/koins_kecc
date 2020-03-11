module Reports
  class GenerateKalingaExcelReport
    def initialize(branch:, start_date:, end_date:)
      @start_date   = start_date
      @end_date     = end_date
      @branch       = branch

      if @branch.present? && @start_date.present? && @end_date.present?
        @kalinga   = Claim.where("data->>'date_approved' >= ? AND data->>'date_approved' <= ? AND branch_id = ? AND claim_type = ?", @start_date, @end_date, @branch, "K-KALINGA").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @kalinga   = Claim.where("data->>'date_approved' >= ? AND data->>'date_approved' <= ? AND claim_type = ?", @start_date, @end_date, "K-KALINGA").order("created_at DESC")
      elsif @branch.present?
        @kalinga   = Claim.where("branch_id = ? AND claim_type = ?", @branch, "K-KALINGA").order("created_at DESC")
      else
        @kalinga = Claim.where(claim_type: 'K-KALINGA')
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
            "Name of Member",
            "Policy Number",
            "Date Approved",
            "Gender",
            "Civil Status",
            "Date of Birth",
            "Name of Beneficiary",
            "Classification",
            "Name of Insured",
            "Insured Address",
            "Date of Incident or Death",
            "Reason of Death",
            "Amount",
            "Effective Date",
            "Expiration Date",
            "Prepared by"
          ], style: header

          @kalinga.each_with_index do |kalinga|
              sheet.add_row [
                  kalinga.date_prepared.try(:strftime, "%b %d, %Y"),
                  kalinga.branch.cluster.name,
                  kalinga.branch.name,
                  kalinga.member.full_name,
                  kalinga.data["poc_number"],
                  kalinga.data["date_approved"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kalinga.data["gender"],
                  kalinga.data["civil_status"],
                  kalinga.data["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kalinga.data["name_of_beneficiary"],
                  kalinga.data["relationship_to_member"],
                  kalinga.data["name_of_insured"],
                  kalinga.data["insured_address"],
                  kalinga.data["date_of_death_or_incident"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kalinga.data["reason_of_death"],
                  kalinga.data["amount"],
                  kalinga.data["effective_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kalinga.data["expiration_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kalinga.prepared_by
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
