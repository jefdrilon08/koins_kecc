module Reports
  class GenerateCollectionsBlipReportExcel
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
            "Policy Number (ID Number)",
            "Certificate Number / ID Number",
            "Sum Assure / Face Amount",
            "Premium (LIFE)",
            "Premium (RF)",
            "Premium Tax",
            "Amount Collected (LIFE)",
            "Amount Collected (RF)",
            "Official Receipt (voucher check number)",
            "OR Date (date of release)",
          ], style: header

          @members.each_with_index do |member, index|
            current_date = @end_date
            recognition_date = member.try(:recognition_date).try(:to_date)
            
            if !recognition_date.nil?  
              seconds_between = (current_date.to_time - recognition_date.to_time).abs
              days_between = seconds_between / 60 / 60 / 24
              number_of_months = (days_between / 30.44).floor
              years = (days_between / 365.242199).floor
              months = number_of_months - (years * 12)
              if months < 3 && years < 1
                value = 2000
              elsif months >= 3 && years < 1 
                value = 6000
              elsif years >= 1 && years < 2
                value = 10000
              elsif years >= 2 && years < 3
                value = 30000
              elsif years >= 3
                value = 50000
              end
            end  

            official_receipt_dates = []
            official_receipts = []


            life_insurance_type = "Life Insurance Fund"
            member_account = MemberAccount.where("account_subtype = ? AND member_id = ? ", life_insurance_type, member.id)
            life_insurance_account_transactions = AccountTransaction.where("subsidiary_id  = ?", member_account.ids)

            total_life = 0
            total_life_amount = 0
            life = 0
            life_amount = 0
            
            life_insurance_account_transactions.where("transacted_at <= ?", @end_date).each do |liat|
              if liat.transaction_type == "withdraw" || liat.transaction_type == "reversed" || liat.transaction_type == "fund_transfer_withdraw" || liat.transaction_type == "reverse_deposit"
                #life = (life_amount - liat.amount).abs
                life = ((life_amount < 0 ? 0 : life_amount) - (liat.amount < 0 ? 0 : liat.amount))
              elsif liat.transaction_type == "deposit" || liat.transaction_type == "fund_transfer_deposit" || liat.transaction_type == "reverse_withdraw"
                life = (life_amount + liat.amount).abs
              end
              life_amount = life
            end

            life_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ?", @start_date, @end_date).each do |liat|
              if liat.transaction_type == "withdraw" || liat.transaction_type == "reversed" || liat.transaction_type == "fund_transfer_withdraw" || liat.transaction_type == "reverse_deposit"
                #total_life = (total_life_amount - liat.amount).abs
                total_life = ((total_life_amount < 0 ? 0 : total_life_amount) - (liat.amount < 0 ? 0 : liat.amount))
              elsif liat.transaction_type == "deposit" || liat.transaction_type == "fund_transfer_deposit" || liat.transaction_type == "reverse_withdraw"
                total_life = (total_life_amount + liat.amount).abs
              end

              if total_life < 0
                total_life_amount = 0
              else  
                total_life_amount = total_life
              end  

            
              or_number = AccountingEntry.where(reference_number: liat.data.with_indifferent_access['accounting_entry_reference_number'], particular: liat.data.with_indifferent_access['accounting_entry_particular']).first.try(:data)
              if or_number.nil? 
                official_receipts << nil
                official_receipt_dates << liat.transacted_at.strftime("%B %d, %Y")
              else
                official_receipts << or_number['or_number']
                official_receipt_dates << liat.transacted_at.strftime("%B %d, %Y")
              end
            end

            rf_insurance_type = "Retirement Fund"
            member_account = MemberAccount.where("account_subtype = ? AND member_id = ? ", rf_insurance_type, member.id)
            rf_insurance_account_transactions = AccountTransaction.where("subsidiary_id  = ?", member_account.ids)
            total_rf = 0
            total_rf_amount = 0
            rf = 0
            rf_amount = 0
            rf_insurance_account_transactions.where("transacted_at <= ?", @end_date).each do |riat|
              if riat.transaction_type == "withdraw" || riat.transaction_type == "reversed" || riat.transaction_type == "fund_transfer_withdraw" || riat.transaction_type == "reverse_deposit"
                #rf = (rf_amount - riat.amount).abs
                rf = ((rf_amount < 0 ? 0 : rf_amount) - (riat.amount < 0 ? 0 : riat.amount))
              elsif riat.transaction_type == "deposit" || riat.transaction_type == "fund_transfer_deposit" || riat.transaction_type == "reverse_withdraw"
                rf = (rf_amount + riat.amount).abs
              end
              rf_amount = rf
            end


            rf_insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ?", @start_date, @end_date).each do |riat|
              if riat.transaction_type == "withdraw" || riat.transaction_type == "reversed" || riat.transaction_type == "fund_transfer_withdraw" || riat.transaction_type == "reverse_deposit"
                #total_rf = (total_rf_amount - riat.amount).abs
                total_rf = ((total_rf_amount < 0 ? 0 : total_rf_amount) - (riat.amount < 0 ? 0 : riat.amount))
              elsif riat.transaction_type == "deposit" || riat.transaction_type == "fund_transfer_deposit" || riat.transaction_type == "reverse_withdraw"
                total_rf = (total_rf_amount + riat.amount).abs
              end

              if total_rf < 0
                total_rf_amount = 0
              else  
                total_rf_amount = total_rf
              end
            end

            if index == 0
              sheet.add_row [
                  "",
                  member.full_name_titleize,
                  member.identification_number,
                  member.identification_number,
                  value,
                  life_amount,
                  rf_amount,
                  "",
                  total_life_amount,
                  total_rf_amount,
                  official_receipts.join(', '),
                  official_receipt_dates.join(', '),
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              else
                sheet.add_row [
                  "",
                  member.full_name_titleize,
                  member.identification_number,
                  member.identification_number,
                  value,
                  life_amount,
                  rf_amount,
                  "",
                  total_life_amount,
                  total_rf_amount,
                  official_receipts.join(', '),
                  official_receipt_dates.join(', '),
                ], style: [nil, nil, date_format_cell, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
            end
          end
        end
      end

      @p
    end
  end
end
