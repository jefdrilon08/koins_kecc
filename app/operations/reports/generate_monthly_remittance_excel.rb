module Reports
  class GenerateMonthlyRemittanceExcel
    def initialize(start_date:, end_date:, branch_id:)
      @start_date   = start_date
      @end_date     = end_date
      @branch_id    = branch_id

      if @branch_id.present?
        @branch       = Branch.where(id: @branch_id).first
      else
        @branch       = Branch.all
      end

      @account_type = "INSURANCE"

      @data_rf = ::MemberAccounts::FetchMembersFromTransactions.new(
                                                                config: {
                                                                  start_date: @start_date,
                                                                  end_date: @end_date,
                                                                  branch: @branch,
                                                                  account_type: @account_type,
                                                                  account_subtype: "Retirement Fund"
                                                                }
                                                            ).execute!

      @data_lif = ::MemberAccounts::FetchMembersFromTransactions.new(
                                                                config: {
                                                                  start_date: @start_date,
                                                                  end_date: @end_date,
                                                                  branch: @branch,
                                                                  account_type: @account_type,
                                                                  account_subtype: "Life Insurance Fund"
                                                                }
                                                            ).execute!

      @new_members = Member.where("data ->> 'recognition_date' >= ? AND data ->> 'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date.to_date, @branch.id)
      @membership_fee = @new_members.count * 100

      
      @member_account_validations = MemberAccountValidation.approved.where("date_approved >= ? AND date_approved <= ? AND branch_id = ?", @start_date, @end_date, @branch.id) 

      @total_50_percent_life = 0
      @total_advance_life = 0
      @total_interest = 0
      @total_rf = 0

      @member_account_validations.each do |iav|
        iav.member_account_validation_records.each_with_index do |iavr, index|
          @total_rf = @total_rf + iavr.rf
          @total_50_percent_life = @total_50_percent_life + iavr.lif_50_percent
          @total_advance_life = @total_advance_life + iavr.advance_lif
          @total_interest = @total_interest + iavr.interest
        end
      end

      # trial_balance_data  = ::Accounting::GenerateTrialBalance.new(config: { start_date: @start_date.to_date, end_date: @end_date.to_date, branch: @branch }).execute!

      # trial_balance_data[:accounting_codes].each_with_index do |d, i|
      #   if d[:name] == "Payable to MBA - RF"
      #     @dr_ret_fee = trial_balance_data[:current_entries][i][:dr_amount]
      #     @cr_ret_fee = trial_balance_data[:current_entries][i][:cr_amount]
      #     # @ret_fee = @cr_ret_fee - @dr_ret_fee
      #     # if @ret_fee == 0
      #       @ret_fee = @cr_ret_fee
      #     # end
      #   elsif d[:name] == "Payable to MBA-LIF"
      #     @dr_life = trial_balance_data[:current_entries][i][:dr_amount]
      #     @cr_life = trial_balance_data[:current_entries][i][:cr_amount]
      #     # @life = @cr_life - @dr_life
      #     # if @life == 0
      #       @life = @cr_life
      #     # end
      #   elsif d[:name] == "Payable to MBA Mem. Fee "
      #     @dr_mem_fee = trial_balance_data[:current_entries][i][:dr_amount]
      #     @cr_mem_fee = trial_balance_data[:current_entries][i][:cr_amount]  
      #     @mem_fee = @cr_mem_fee - @dr_mem_fee
      #     if @mem_fee == 0
      #       @mem_fee = @cr_mem_fee
      #     end
      #   end
      # end

      # @collection_fee = ((@ret_fee + @life) * 0.05)

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

        sheet.add_row ["Monthly Collection Report"], style: title_cell
        sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
        sheet.add_row []

        # For header
        sheet.add_row [ 
          "FIELD OFFICE",
          "LIFE",
          "ADVANCE LIFE",
          "EQUITY VALUE",
          "RET. FEE",
          "RF WITHDRAWALS",
          "REC'L FROM MBA (interest)",
          "MEM. FEE",
          "COLLECTION FEES",
          "KDCI WITHDRAWALS",
          "TOTAL"
          ], style: header

          sheet.add_row [ 
          @branch,
          # @life,
          "",
          @total_advance_life,
          @total_50_percent_life,
          # @ret_fee,
          "",
          @total_rf,
          @total_interest,
          @membership_fee,
          "",
          # @collection_fee,
          "",
          "",
          ""
          ], style: [ header, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right ] 
       
        sheet.add_row []       
        sheet.add_row ["LIFE TRANSACTIONS"], style: header
        sheet.add_row [
          "FIRST NAME",
          "MIDDLE NAME",
          "LAST NAME",
          "CENTER",
          "AMOUNT",
          "TRANSACTIONS TYPE"
          ], style: header

        @data_lif[:members].each do |member|
          member[:transactions].each do |trans|
          sheet.add_row [ 
            member[:member][:first_name], 
            member[:member][:middle_name], 
            member[:member][:last_name], 
            member[:center][:name],
            trans[:amount], 
            trans[:transaction_type]
            ], style: [ default_cell, default_cell, default_cell, default_cell, currency_cell_right, default_cell] 
          end
        end

        # DAPAT UNG VALUE IS DEBIT MINUS CREDIT
        sheet.add_row [ "Total LIFE Withdrawals", @data_lif[:total_withdrawals].to_f ], style: [ header, currency_cell_right_bold ]
        sheet.add_row [ "Total LIFE Deposits", @data_lif[:total_deposits].to_f ], style: [ header, currency_cell_right_bold ]
        
        sheet.add_row []       
        sheet.add_row ["RF TRANSACTIONS"], style: header
        sheet.add_row [
          "FIRST NAME",
          "MIDDLE NAME",
          "LAST NAME",
          "CENTER",
          "AMOUNT",
          "TRANSACTIONS TYPE"
          ], style: header

        @data_rf[:members].each do |member|
          member[:transactions].each do |trans|
          sheet.add_row [ 
            member[:member][:first_name], 
            member[:member][:middle_name], 
            member[:member][:last_name], 
            member[:center][:name],
            trans[:amount], 
            trans[:transaction_type]
            ], style: [ default_cell, default_cell, default_cell, default_cell, currency_cell_right, default_cell] 
          end
        end

        # DAPAT UNG VALUE IS DEBIT MINUS CREDIT
        sheet.add_row [ "Total RF Withdrawals", @data_rf[:total_withdrawals].to_f ], style: [ header, currency_cell_right_bold ]
        sheet.add_row [ "Total RF Deposits", @data_rf[:total_deposits].to_f ], style: [ header, currency_cell_right_bold ]
        end
      end
      
      @p
    end
  end
end
