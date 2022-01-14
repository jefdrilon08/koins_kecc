module Reports
  class GenerateSeriatimReportExcel
    def initialize(as_of:, branch:)
      @as_of = as_of
      @branch = branch
      @valid_members = []


      if @as_of.present? && @branch.present?
        if Settings.activate_microloans
          @members  = Member.where("data->>'recognition_date' <= ? AND member_type != ? AND insurance_status NOT IN (?) AND status IN (?) AND branch_id = ?", @as_of.to_date, "GK", ["resigned", "pending"], ["active", "resigned", "pending"], @branch).order("insurance_status ASC")
          @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned > ? AND insurance_status = ? AND branch_id = ?", @as_of.to_date, @as_of.to_date, "resigned", @branch).order("insurance_status ASC")
          @valid_members = @members + @resigned   
        elsif Settings.activate_microinsurance
          @members  = Member.where("data->>'recognition_date' <= ? AND member_type != ? AND insurance_status NOT IN (?) AND status = ? AND branch_id = ?", @as_of.to_date, "GK", ["resigned", "pending"], "active", @branch).order("insurance_status ASC")          
          @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned > ? AND insurance_status = ? AND branch_id = ?", @as_of.to_date, @as_of.to_date, "resigned", @branch).order("insurance_status ASC")
          @valid_members = @members + @resigned
        end
      elsif @as_of.present?  
        if Settings.activate_microloans
          @members  = Member.where("data->>'recognition_date' <= ? AND member_type != ? AND insurance_status NOT IN (?) AND status IN (?)", @as_of.to_date, "GK", ["resigned", "pending"], ["active", "resigned", "pending"]).order("insurance_status ASC")
          @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned > ? AND insurance_status = ?", @as_of.to_date, @as_of.to_date, "resigned").order("insurance_status ASC")
          @valid_members = @members + @resigned       
        elsif Settings.activate_microinsurance
          @members  = Member.where("data->>'recognition_date' <= ? AND member_type != ? AND insurance_status NOT IN (?) AND status = ?", @as_of.to_date, "GK", ["resigned", "pending"], "active").order("insurance_status ASC")          
          @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned > ? AND insurance_status = ?", @as_of.to_date, @as_of.to_date, "resigned").order("insurance_status ASC")
          @valid_members = @members + @resigned
        end
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
            "Certificate Number",
            "Name of Member",
            "Status",
            "Insurance Status",
            "Date Resigned",
            "Date of Membership",
            "Basic Benefit",
            "Mode of Contribution (weekly/monthly)",
            "Contribution per week/month",
            "Member's contribution due & uncollected",
            "Total accumulated contributions (LIFE)",
            "Interest on equity value, if any",
            "Interest on RF, if any",
            "RF",
            "Total Equity Value",
            "Rerserves",
            "Policy Number",
            "Policy/Effectivity Date",
            "Face Amount",
            "Modal Premium (annual,semi-annual,quarterly,monthly)",
            "Net Premiums due & uncollected",
            "Last due date",
            "Cash Value (Premium)",
            "Rerserves",
            "Loan maturity date",
            "Loan num of num installments",
            # "Dependent Name",
            # "Relationship to Member",
            # "Rerserves",
            # "Date of birth",
            # "Age"
          ], style: header

          @members.each_with_index do |member, index|
            @active_loans = []
            current_date = @as_of
            recognition_date = member.data.with_indifferent_access[:recognition_date].try(:to_date)
            
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

            # lif_member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Life Insurance Fund", member.id).first
            # lif_account_transactions = AccountTransaction.where("amount > 0 AND subsidiary_id IN (?)", lif_member_accounts.id)

            # life_amount = 0

            # lif_account_transactions.where("transacted_at <= ?", @as_of).order("transacted_at ASC").each do |at|
            #   if at.transaction_type == "withdraw"
            #     life = ((life_amount < 0 ? 0 : life_amount) - (at.amount < 0 ? 0 : at.amount))
            #   elsif at.transaction_type == "deposit"
            #     life = (life_amount + at.amount).abs
            #   end
            #   life_amount = life
            # end

            rf_member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Retirement Fund", member.id).first
            rf_account_transactions = AccountTransaction.where("amount > 0 AND subsidiary_id IN (?)", rf_member_accounts.id)

            rf_amount = 0.0
            rf_interest = 0.0
            rf_account_transactions.where("transacted_at <= ?", @as_of).order("transacted_at ASC").each do |at|
              if at.transaction_type == "withdraw"
                rf_amount = ((rf_amount < 0 ? 0 : rf_amount) - (at.amount < 0 ? 0 : at.amount))
              elsif at.transaction_type == "deposit"
                rf_amount = (rf_amount + at.amount).abs
              end

              if at.transaction_type == "deposit"
                if at.data.with_indifferent_access[:is_interest] == true 
                  if at.transacted_at >= "2021-09-01".to_date
                    rf_interest = (rf_interest + at.amount).abs
                  end          
                end
              end
            end

            rf_amount = rf_amount - rf_interest

            ev_member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Equity Value", member.id).first
            ev_account_transactions = AccountTransaction.where("amount > 0 AND subsidiary_id IN (?)", ev_member_accounts.id)

            ev_interest = 0.0
            ev_amount = 0.0
            ev_account_transactions.where("transacted_at <= ?", @as_of).order("transacted_at ASC").each do |at|
              if at.transaction_type == "withdraw"
                ev_amount = ((ev_amount < 0 ? 0 : ev_amount) - (at.amount < 0 ? 0 : at.amount))
              elsif at.transaction_type == "deposit"
                ev_amount = (ev_amount + at.amount).abs
              end

              if at.transaction_type == "deposit"
                if at.data.with_indifferent_access[:is_interest] == true 
                  if at.transacted_at >= "2021-09-01".to_date
                    ev_interest = (ev_interest + at.amount).abs
                  end          
                end
              end
            end

            ev_amount = ev_amount - ev_interest

            if index == 0
              sheet.add_row [
                  member.identification_number,
                  member.full_name_titleize,
                  member.status,
                  member.insurance_status,
                  member.insurance_date_resigned,
                  member.data.with_indifferent_access[:recognition_date].try(:to_date),
                  value,
                  "weekly",
                  20,
                  "",
                  ev_amount*2,
                  ev_interest,
                  rf_interest,
                  rf_amount,
                  ev_amount,
                  "",
                ], style: [nil, nil,nil,nil, date_format_cell,date_format_cell,currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, nil]
              else
                sheet.add_row [
                  member.identification_number,
                  member.full_name_titleize,
                  member.status,
                  member.insurance_status,
                  member.insurance_date_resigned,
                  member.data.with_indifferent_access[:recognition_date].try(:to_date),
                  value,
                  "weekly",
                  20,
                  "",
                  ev_amount*2,
                  ev_interest,
                  rf_interest,
                  rf_amount,
                  ev_amount,
                  "",
                ], style: [nil, nil,nil,nil, date_format_cell, date_format_cell,currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, currency_cell_right, currency_cell_right, currency_cell_right, nil]
            end

          loans = member.loans.where("status = ? AND date_approved <= ?","active", @as_of)
          loans.each do |loan|
            accounting_entry = loan.accounting_entry
            if !accounting_entry.nil?
              clip = accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
              if !clip.nil?
                @active_loans << loan
              end
            end
          end


          # member.loans.joins(:member).insured.where("date_approved <= ?", @as_of).order("date_prepared ASC").each_with_index do |loan, i|
          @active_loans.each_with_index do |loan, i|  
            if !loan.nil?
              lde = loan.accounting_entry.journal_entries.where(accounting_code_id: 'af83062d-628a-4fdd-acfd-bdebe2696513').first
              if lde.present?
                premium = lde.amount
              else
                raise "Invalid loan deduction entry"
              end
  
              if i == 0
                sheet.add_row [
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  loan.pn_number,
                  loan.date_approved,
                  loan.principal,
                  loan.term,
                  "",
                  "",
                  premium,
                  "",
                  loan.maturity_date,
                  loan.num_installments,
                ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  date_format_cell, currency_cell_right, nil, nil, nil, currency_cell_right, nil, date_format_cell, nil]
              else
                sheet.add_row [
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  "",
                  loan.pn_number,
                  loan.date_approved,
                  loan.principal,
                  loan.term,
                  "",
                  "",
                  premium,
                  "",
                  loan.maturity_date,
                  loan.num_installments,
                ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  date_format_cell, currency_cell_right, nil, nil, nil, currency_cell_right, nil, date_format_cell, nil]
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
