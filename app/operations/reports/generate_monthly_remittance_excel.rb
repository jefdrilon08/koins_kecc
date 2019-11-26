module Reports
  class GenerateMonthlyRemittanceExcel
    def initialize(start_date:, end_date:, branch:)
      @start_date   = start_date
      @end_date     = end_date
      @branch       =  branch

      if @branch.present?
        @branches       = Branch.where(id: @branch.id)
      else
        @branches       = Branch.where("cluster_id IN (?)", ["4350b839-9774-4b0a-a79b-f71409ad6d2b", "168eb8bf-59b4-4401-9498-79c87b3c01d4"]).order("cluster_id ASC, name ASC")
      end

      @p = Axlsx::Package.new
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

        sheet.add_row ["Monthly Remittance Report"], style: title_cell
        sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
        sheet.add_row []

        # For header
        sheet.add_row [ 
          "FIELD OFFICE",
          "DEPOSIT COLLECTION OF LIFE",
          "DEPOSIT COLLECTION OF RF",
          "ADVANCE LIFE",
          "EQUITY VALUE",
          "RF WITHDRAWALS",
          "REC'L FROM MBA (interest)",
          "MEM. FEE",
          "TOTAL"
          ], style: header

          @branches.each do |branch|
            total_per_branch = 0.00

            total_50_percent_life = 0.00
            total_advance_life = 0.00
            total_interest = 0.00
            total_rf = 0.00

            member_account_validations = MemberAccountValidation.approved.where("date_approved >= ? AND date_approved <= ? AND branch_id = ?", @start_date, @end_date, branch.id) 

            member_account_validations.each do |iav|
              iav.member_account_validation_records.each_with_index do |iavr, index|
                total_rf = total_rf + iavr.rf
                total_50_percent_life = total_50_percent_life + iavr.lif_50_percent
                total_advance_life = total_advance_life + iavr.advance_lif
                total_interest = total_interest + iavr.interest + iavr.equity_interest
              end
            end

            new_members = Member.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date.to_date, branch.id)            
            membership_fee = new_members.count * 100

            deposit_collections = DepositCollection.approved.where("date_approved >= ? AND date_approved <= ? AND branch_id = ?", @start_date, @end_date, branch.id)
            
            total_deposit_lif = 0.00
            total_deposit_rf = 0.00

            deposit_collections.each do |deposit_collection|
              deposit_collection_data = deposit_collection.data.with_indifferent_access

              deposit_collection_data[:totals].each do |total|
                if total[:key] == "Life Insurance Fund"
                  total_deposit_lif = total_deposit_lif + total[:amount]
                elsif total[:key] == "Retirement Fund"
                  total_deposit_rf = total_deposit_rf + total[:amount]
                end
              end
            end 

            total_per_branch = total_deposit_rf + total_deposit_lif + total_advance_life + total_50_percent_life + total_rf + total_interest + membership_fee

            sheet.add_row [ 
            branch,
            total_deposit_lif,
            total_deposit_rf,
            total_advance_life,
            total_50_percent_life,
            total_rf,
            total_interest,
            membership_fee,
            total_per_branch
            ], style: [ header, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right ] 
          end
        end
      @p
    end
  end
end
