module Reports
  class GenerateCollectionsClipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @branch = branch


      if @branch.present? && @start_date.present? && @end_date.present?
        @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("identification_number ASC")
      elsif @start_date.present? && @end_date.present?
        @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", @start_date, @end_date).order("identification_number ASC")
      elsif @branch.present?
        @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", Date.today, Date.today, @branch).order("identification_number ASC")
      else
         @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", Date.today, Date.today).order("identification_number ASC") 
      end

      @p        = Axlsx::Package.new
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
            "Number",
            "Name of Member",
            "Policy Number",
            "Certificate Number",
            "Sum Assure / Loan Amount",
            "Premium",
            "Premium Tax",
            "Amount Collected",
            "Official Receipt (voucher check number)",
            "OR Date (date of release)",
            "Check Number",
            "Date of Check",
          ], style: header

           @members.each_with_index do |member, index|
            @active_loans = []
            if index == 0
              sheet.add_row [
                  "",
                  member.full_name_titleize,
                  member.identification_number,
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              else
                sheet.add_row [
                  "",
                  member.full_name_titleize,
                  member.identification_number,
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
            end

            loans = member.loans.where("date_approved >= ? AND date_approved <= ?",@start_date, @end_date)
            loans.each do |loan|
              accounting_entry = loan.accounting_entry
              if !accounting_entry.nil?
                clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
                if !clip.nil?
                   @active_loans << loan
                end
              end
            end
            @active_loans.each_with_index do |loan, i| 
              lde = loan.accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
                if lde.present?
                    @insured_amount = lde.amount
                  if i == 0
                    sheet.add_row [
                      "",
                      "",
                      "",
                      loan.pn_number,
                      loan.principal,
                      @insured_amount,
                      "",
                      @insured_amount,
                      loan.data['voucher']['check_number'],
                      loan.date_released,
                      loan.data['voucher']['bank_check_number'],
                      loan.data['voucher']['date_requested'],
                    ], style: [nil, nil, nil, nil, currency_cell_right, currency_cell_right, nil, currency_cell_right, nil, nil, nil, date_format_cell,]
                  else
                    sheet.add_row [
                      "",
                      "",
                      "",
                      loan.pn_number,
                      loan.principal,
                      @insured_amount,
                      "",
                      @insured_amount,
                      loan.data['voucher']['check_number'],
                      loan.date_released,
                      loan.data['voucher']['bank_check_number'],
                      loan.data['voucher']['date_requested'],
                    ], style: [nil, nil, nil, nil, currency_cell_right, currency_cell_right, nil, currency_cell_right, nil, nil, nil, date_format_cell,]
                  end
                end
              end
            end
          end
        end
      @p
    end
  end
end
