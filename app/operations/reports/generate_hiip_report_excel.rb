module Reports
  class GenerateHiipReportExcel
    def initialize(start_date:, end_date:, branch:)
      @start_date   = start_date
      @end_date     = end_date
      @branch_id    = branch

      if @branch_id.present?
        hiip_accounts = MemberAccount.where("account_subtype = ? AND branch_id = ?", "Hospital Income Insurance Plan", @branch_id)
      else
        hiip_accounts = MemberAccount.where("account_subtype = ?", "Hospital Income Insurance Plan")
      end

      if @start_date.present? && @end_date.present?
        @transactions = AccountTransaction.where("subsidiary_id IN (?) AND transacted_at >= ? AND transacted_at <= ?", hiip_accounts.ids, @start_date.to_date, @end_date.to_date)
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
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :left }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row ["HIIP Report"], style: title_cell
          sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
          sheet.add_row []

          # For header
          sheet.add_row [ 
            "TRANSACTION ID",
            "TRANSACTED AT",
            "IDENTIFICATION NUMBER",
            "MEMBER",
            "BRANCH",
            "AMOUNT"
            ], style: header

          @transactions.each do |transaction|
            member_account = MemberAccount.find(transaction.subsidiary_id)
            member = member_account.member
            
            sheet.add_row [
              transaction.id,
              transaction.transacted_at.try(:to_date),
              member.try(:identification_number),
              member.full_name_titleize,
              member.branch.to_s,
              transaction.amount
              ], style: [ left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, currency_cell_right]
          end
        end
      end
      @p
    end
  end
end
