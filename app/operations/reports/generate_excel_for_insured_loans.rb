module Reports
  class GenerateExcelForInsuredLoans
    def initialize(data:, start_date:, end_date:, loan_status:, branch_id:)
      @data = data
      @start_date = start_date
      @end_date = end_date
      @loan_status = loan_status
      @p      = Axlsx::Package.new
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          label_cell = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          count_cell = wb.styles.add_style  b: true, alignment: { horizontal: :right }, format_code: "0", font_name: "Calibri"
          currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row ["Credit Life Summary"], style: title_cell
          sheet.add_row ["#{Settings.company_name}"], style: title_cell
          sheet.add_row ["#{@loan_status} Loans As of: #{@start_date} - #{@end_date}"], style: title_cell
          sheet.add_row []
          sheet.add_row [
            "Identification Number",
            "Last Name", 
            "First Name", 
            "MI", 
            "PN #",
            "Date Released", 
            "Maturity Date", 
            "Loan Term", 
            "Insured Amount", 
            "Amount", 
            "Loan Product",
            "Status",
            "Gender",
            "Date Of Birth"], 
            style: label_cell

          @insured_amount_total = 0.00
          @loan_amount_total = 0.00
          @count = 0
          @collection_fee = 0.00
          @total_remitance = 0.00

          @data.each_with_index do |data|
            sheet.add_row [ 
              data[:identification_number],
              data[:last_name],
              data[:first_name],
              data[:middle_name],
              data[:pn_number],
              data[:date_released],
              data[:maturity_date],  
              data[:num_installments],
              data[:insured_amount], 
              data[:amount],
              data[:loan_product],
              data[:status],
              data[:gender],
              data[:date_of_birth]
              ],  
              style: [nil, nil, nil, nil, nil,  date_format_cell, date_format_cell, nil, currency_cell, currency_cell, nil, nil]
              @insured_amount_total = @insured_amount_total.try(:to_f) + data[:insured_amount].try(:to_f)
              @loan_amount_total = @loan_amount_total + data[:amount]
              @count = @count + 1
          end
          sheet.add_row []
          sheet.add_row [
            "",
            "", 
            "", 
            "", 
            "", 
            "",
            "TOTAL", 
            @count, 
            @insured_amount_total, 
            @loan_amount_total
            ],
            style: [nil, nil, nil, nil, nil, nil, label_cell, count_cell, currency_cell_right_bold, currency_cell_right_bold]
          sheet.add_row []

          @collection_fee = @insured_amount_total * 0.35
          @total_remitance = @insured_amount_total - @collection_fee

          sheet.add_row [
            "",
            "", 
            "", 
            "", 
            "", 
            "", 
            "PREMIUM",
            @insured_amount_total
            ],
            style: [nil, nil, nil, nil, nil, nil, label_cell, currency_cell_right_bold]
          
          sheet.add_row [
            "",
            "", 
            "", 
            "", 
            "", 
            "", 
          "COLLECTION FEE", 
            @collection_fee
            ],
            style: [nil, nil, nil, nil, nil, nil, label_cell, currency_cell_right_bold]
          
          sheet.add_row [
            "",
            "", 
            "", 
            "", 
            "", 
            "", 
            "TOTAL REMITANCE", 
            @total_remitance
            ],
            style: [nil, nil, nil, nil, nil, nil, label_cell, currency_cell_right_bold]                   
        end
      end
      @p
    end
  end
end
