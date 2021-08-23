module Reports
  class GenerateCalamityClaimsReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch
      
      if @branch.present? && @start_date.present? && @end_date.present?
        @calamity   = Claim.where("data->>'date_requested' >= ? AND data->>'date_requested' <= ? AND branch_id = ? AND claim_type = ? AND status = ?", @start_date, @end_date, @branch, "CALAMITY ASSISTANCE", "approved").order("created_at DESC")
      elsif @start_date.present? && @end_date.present?
        @calamity   = Claim.where("data->>'date_requested' >= ? AND data->>'date_requested' <= ? AND claim_type = ? AND status = ?", @start_date, @end_date, "CALAMITY ASSISTANCE", "approved").order("created_at DESC")
      elsif @branch.present?
        @calamity   = Claim.where("branch_id = ? AND claim_type = ? AND status = ?", @branch, "CALAMITY ASSISTANCE", "approved").order("created_at DESC")
      else
        @calamity = Claim.where(claim_type: 'CALAMITY ASSISTANCE', status: "approved")
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
            "Date Requested",
            "Purpose",
            "Type of Calamity",
            "Amount",
            "Date of Event",
            "Payee",
            "Name of Beneficiary",
            "Prepared by",
            "Status"
          ], style: header

          @calamity.each_with_index do |calamity|
              sheet.add_row [
                  calamity.created_at.try(:strftime, "%b %d, %Y"),
                  calamity.created_at.strftime("%I:%M%P"),
                  calamity.date_prepared.try(:strftime, "%b %d, %Y"),
                  calamity.branch.cluster.name,
                  calamity.branch.name,
                  calamity.center.name,
                  calamity.member.full_name,
                  calamity.member.age,
                  calamity.data["date_requested"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  calamity.data["purpose"],
                  calamity.data["type_of_calamity"],
                  calamity.data["amount"],
                  calamity.data["date_of_event"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  calamity.data["name_of_payee"],
                  calamity.data["name_of_beneficiary"],
                  calamity.prepared_by,
                  calamity.status
                ], style: [nil]             
              end
          end
        end
      @p
    end
  end
end
