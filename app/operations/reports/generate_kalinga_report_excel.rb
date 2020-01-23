module Reports
  class GenerateKalingaReportExcel
    def initialize(branch:, cluster:, start_date:, end_date:)
      @start_date   = start_date
      @end_date     = end_date
      @cluster      = cluster
      @branch       = branch

      if @cluster.present? && @branch == "--ALL--"
        @cluster_branch   = Branch.where(cluster_id: @cluster)
        @kalinga_claim    = KalingaClaim.where("date_reported >= ? AND date_reported <= ? AND member_branch IN (?)", @start_date, @end_date, @cluster_branch.ids)
      else
        @kalinga_claim    = KalingaClaim.where("date_reported >= ? AND date_reported <= ? AND member_branch IN (?)", @start_date, @end_date, @branch)
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
            "Date Reported",
            "Date Emailed",
            "Date Approved",
            "Date Requested",
            "Name of Member",
            "Policy Number",
            "Branch",
            "Identification Number",
            "Gender",
            "Civil Status",
            "Date of Birth",
            "Name of Beneficiary",
            "Classification",
            "Name of Insured",
            "Insured Address",
            "Date of Incident or Death",
            "Reason of Death",
            "Purpose",
            "Amount",
            "Issued Date",
            "Effective Date",
            "Expiration Date"
          ], style: header

          @kalinga_claim.each_with_index do |kalinga_claim|
              sheet.add_row [
                  kalinga_claim.date_reported.strftime("%b %d, %Y"),
                  kalinga_claim.date_emailed.strftime("%b %d, %Y"),
                  kalinga_claim.date_approved.strftime("%b %d, %Y"),
                  kalinga_claim.date_requested.strftime("%b %d, %Y"),
                  kalinga_claim.name_of_member,
                  kalinga_claim.poc_number,
                  kalinga_claim.branch_name,
                  kalinga_claim.member_identification_number,
                  kalinga_claim.gender,
                  kalinga_claim.civil_status,
                  kalinga_claim.date_of_birth.strftime("%b %d, %Y"),
                  kalinga_claim.name_of_beneficiary,
                  kalinga_claim.relationship_to_member,
                  kalinga_claim.name_of_insured,
                  kalinga_claim.insured_address,
                  kalinga_claim.date_of_death_or_incident.strftime("%b %d, %Y"),
                  kalinga_claim.reason_of_death,
                  kalinga_claim.purpose,
                  kalinga_claim.amount,
                  kalinga_claim.issueddate.strftime("%b %d, %Y"),
                  kalinga_claim.effective_date.strftime("%b %d, %Y"),
                  kalinga_claim.expiration_date.strftime("%b %d, %Y")
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
