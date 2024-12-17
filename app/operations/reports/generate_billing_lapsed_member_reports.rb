module Reports
  class GenerateBillingLapsedMemberReports
    def initialize(branch:, collection_date_from:, collection_date_to:, status:)
      @branch_id              = branch
      @collection_date_from   = collection_date_from
      @collection_date_to     = collection_date_to
      @status                 = status

      @clip = Billing.where("collection_date >= ? AND collection_date <= ? AND branch_id = ? AND status = ?", @collection_date_from, @collection_date_to, @branch_id, @status).order("collection_date DESC")
      @p        = Axlsx::Package.new
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
          right_aligned_cell = wb.styles.add_style alignment: { horizontal: :right }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"
          premium_total = 0
          member_count = 0

          sheet.add_row ["Lapsed Members with payment without reinstatement"], style: title_cell

          if @collection_date_from.present? && @collection_date_to.present?
            sheet.add_row ["Collection Date From: #{@collection_date_from} to #{@collection_date_to}"], style: title_cell
          end

          sheet.add_row []

          sheet.add_row [
            "Branch",
            "Center",
            "MemberName",
            "InsuranceStatus"
          ], style: header
          @clip.each do |clip|
          # @clip_data = clip.data.with_indifferent_access
          # raise clip[:data][:records][0].inspect
            clip[:data]["records"].each_with_index do |o, index|
            
              sheet.add_row [
                clip.branch.name,
                clip.center.name,
                o["member"]["full_name"],
                o["member"]["insurance_status"]
                
              ], style: [left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell]
            end
          end

        end
      end
      @p
    end
  end
end
