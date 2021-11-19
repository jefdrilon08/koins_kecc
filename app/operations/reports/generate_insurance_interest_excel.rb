module Reports
  class GenerateInsuranceInterestExcel
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
          "MEMBER NAME",
          "INTEREST EARNED RETIREMENT FUND",
          "INTEREST EARNED EQUITY VALUE"
          ], style: header

          @branches.each do |branch|
            rf_member_accounts = MemberAccount.where(branch_id: branch.id, account_subtype: "Retirement Fund")
            ev_member_accounts = MemberAccount.where(branch_id: branch.id, account_subtype: "Equity Value")

            ev_account_transactions = AccountTransaction.where("data->>'is_interest' = ? AND transacted_at >= ? AND transacted_at <= ? AND subsidiary_id IN (?)", "true", @start_date, @end_date, ev_member_accounts.ids)
            rf_account_transactions = AccountTransaction.where("data->>'is_interest' = ? AND transacted_at >= ? AND transacted_at <= ? AND subsidiary_id IN (?)", "true", @start_date, @end_date, rf_member_accounts.ids)

            total_per_branch = 0.00
            total_ev_interest = 0.00
            total_rf_interest = 0.00
            total_interest = 0.00

            Member.where(branch_id: branch.id).each do |member|
              rf_account = rf_member_accounts.where(account_subtype:"Retirement Fund", member_id: member.id).first
              ev_account = ev_member_accounts.where(account_subtype:"Equity Value", member_id: member.id).first

              rf_insterest_amount = rf_account_transactions.where(subsidiary_id: rf_account).sum(:amount)
              ev_insterest_amount = ev_account_transactions.where(subsidiary_id: ev_account).sum(:amount)
            
              member_row  = []
              
              if rf_insterest_amount > 0
                member_row  <<  branch
                member_row  <<  member.full_name_middle_initial
                member_row  << rf_insterest_amount
                member_row  << ev_insterest_amount

                sheet.add_row member_row 
              end
            end
          end
        end
      end
      @p
    end
  end
end
