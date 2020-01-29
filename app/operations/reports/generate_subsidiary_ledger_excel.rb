module Reports
  class GenerateSubsidiaryLedgerExcel
    def initialize(as_of:, branch:)
      @as_of                    = as_of
      @branch                   = branch
      @members                  = Member.where("branch_id = ?", @branch)
      @member_accounts          = MemberAccount.insurance.where(member_id: @members.ids)
      @account_transactions     = AccountTransaction.where("subsidiary_id IN (?) AND transacted_at <= ?", @member_accounts.ids, @as_of)
      @p                        = Axlsx::Package.new
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

          # For header
          sheet.add_row [ 
            "Identification Number",
            "Name",
            "Branch",
            "Center",
            "Status",
            "LIF",
            "RF"
          ], 
          style: default_cell
          

          # For individual data info
           @members.each_with_index do |member, index|
            total_life = 0.00
            total_rf = 0.00

            @lif_current_member_account = @member_accounts.where("member_id = ? AND account_subtype = ?", member.id, "Life Insurance Fund").first
            @rf_current_member_account = @member_accounts.where("member_id = ? AND account_subtype = ?", member.id, "Retirement Fund").first
            
            if !@lif_current_member_account.nil?  
              @transactions  = @account_transactions.select{ |o| o.subsidiary_id == @lif_current_member_account.id }
              @transactions.each do |trans|
                total_life = (total_life + trans.amount)
              end
            end

            if !@rf_current_member_account.nil?  
              @transactions  = @account_transactions.select{ |o| o.subsidiary_id == @rf_current_member_account.id }
              @transactions.each do |trans|
                total_rf = total_rf + trans.amount 
              end
            end

              sheet.add_row [
                member.identification_number,
                member.full_name,
                member.branch.name,
                member.center.name,
                member.status,
                total_life.round(2),
                total_rf.round(2)
              ], style: default_cell 
          end
        end
      end
      @p
    end
  end
end

