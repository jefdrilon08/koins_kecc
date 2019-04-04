module MemberAccountValidations
  class GenerateValidationsReportExcel
    def initialize(branch:, status:, start_date:, end_date:)
      @start_date = start_date
      @end_date = end_date
      @status = status
      @branch = branch

      if @status == "approved"
        @member_account_validations = MemberAccountValidation.where("branch_id = ? AND status = ? AND date_approved >= ? AND date_approved <= ? ", @branch, @status, @start_date, @end_date)
      elsif @status == "pending"
        @member_account_validations = MemberAccountValidation.where("branch_id = ? AND status = ? AND date_prepared >= ? AND date_prepared <= ? ", @branch, @status, @start_date, @end_date)   
      elsif @status == "for-approval"
        @member_account_validations = MemberAccountValidation.where("branch_id = ? AND status = ? AND date_validated >= ? AND date_validated <= ? ", @branch, @status, @start_date, @end_date)        
      elsif @status == "for-validation"
        @member_account_validations = MemberAccountValidation.where("branch_id = ? AND status = ? AND date_checked >= ? AND date_checked <= ? ", @branch, @status, @start_date, @end_date)
      end

      @p        = Axlsx::Package.new

      @total_life = 0
      @total_rf = 0
      @total_50_percent_life = 0
      @total_advance_life = 0
      @total_advance_rf = 0
      @total_interest = 0
      @grand_total = 0
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
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row [
            "#{@status.upcase} VALIDATIONS REPORT AS OF : #{@start_date.to_date} - #{@end_date.to_date}"
            ],style: header
          
          sheet.add_row []
          
          sheet.add_row [ 
            "Name of Member",
            "Recognition Date",
            "Center",
            "Resignation Date",
            "Status",
            "Transaction Number",
            "LIFE",
            "RF",
            "LIFE 50 Percent",
            "Advance LIFE",
            "Advance RF",
            "Interest",
            "Total"
          ], style: header

          @member_account_validations.each do |iav|
            iav.member_account_validation_records.each_with_index do |iavr, index|
              lif_account = iavr.member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").first
              AccountTransaction.where(subsidiary_id: lif_account.id, subsidiary_type: "MemberAccount").order("transacted_at ASC").last.data.with_indifferent_access[:beginning_balance]

              if index == 0
                sheet.add_row [
                    iavr.member.full_name,
                    iavr.member.data.with_indifferent_access[:recognition_date],
                    iavr.member.center.name,
                    iavr.resignation_date,
                    iavr.status,
                    iavr.transaction_number,
                    AccountTransaction.where(subsidiary_id: lif_account.id, subsidiary_type: "MemberAccount").order("transacted_at ASC").last.data.with_indifferent_access[:beginning_balance].to_i,
                    iavr.rf,
                    iavr.lif_50_percent,
                    iavr.advance_lif,
                    iavr.advance_rf,
                    iavr.interest,
                    iavr.total
                  ], style: [nil, nil, nil, date_format_cell, nil, nil, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right]
                else
                  sheet.add_row [
                    iavr.member.full_name,
                    iavr.member.data.with_indifferent_access[:recognition_date],
                    iavr.member.center.name,
                    iavr.resignation_date,
                    iavr.status,
                    iavr.transaction_number,
                    AccountTransaction.where(subsidiary_id: lif_account.id, subsidiary_type: "MemberAccount").order("transacted_at ASC").last.data.with_indifferent_access[:beginning_balance].to_i,
                    iavr.rf,
                    iavr.lif_50_percent,
                    iavr.advance_lif,
                    iavr.advance_rf,
                    iavr.interest,
                    iavr.total
                  ], style: [nil, nil, nil, date_format_cell, nil, nil, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right]
              end

              @total_life = @total_life + AccountTransaction.where(subsidiary_id: lif_account.id, subsidiary_type: "MemberAccount").order("transacted_at ASC").last.data.with_indifferent_access[:beginning_balance].to_i
              @total_rf = @total_rf + iavr.rf
              @total_50_percent_life = @total_50_percent_life + iavr.lif_50_percent
              @total_advance_life = @total_advance_life + iavr.advance_lif
              @total_advance_rf = @total_advance_rf + iavr.advance_rf
              @total_interest = @total_interest + iavr.interest
              @grand_total = @grand_total + iavr.total

            end  
          end

          sheet.add_row [ 
            "TOTAL",
            "",
            "",
            "",
            "",
            "",
            @total_life,
            @total_rf,
            @total_50_percent_life,
            @total_advance_life,
            @total_advance_rf,
            @total_interest,
            @grand_total
          ], style: [header, nil, nil, nil, nil, nil, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold]

        end
      end

      @p
    end
  end
end
