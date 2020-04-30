module Reports
  class GenerateSeriatimReportExcel
    def initialize(as_of:, branch:)
      @as_of = as_of
      @branch = branch

      if @as_of.present? && @branch.present?
        @active_members  = Member.active.where("data->>'recognition_date' <= ? AND insurance_status != ? AND member_type != ? AND branch_id = ?", @as_of, "dormant", "GK", @branch).order("identification_number ASC")
        @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned >= ? AND branch_id = ? ", @as_of, @as_of, @branch)
        @members = @active_members + @resigned   
      elsif @as_of.present?  
        @active_members  = Member.active.where("data->>'recognition_date' <= ? AND insurance_status != ? AND member_type != ?", @as_of, "dormant", "GK").order("identification_number ASC")
        @resigned = Member.where("data->>'recognition_date' <= ? AND insurance_date_resigned >= ? ", @as_of, @as_of)
        @members = @active_members + @resigned      
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
            "Date Resigned",
            "Date of Membership",
            "Basic Benefit",
            "Mode of Contribution (weekly/monthly)",
            "Contribution per week/month",
            "Member's contribution due & uncollected",
            "Total accumulated contributions (LIFE)",
            "Interest on equity value, if any",
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

            member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Life Insurance Fund", member.id).first
            account_transactions = AccountTransaction.where("amount > 0 AND subsidiary_id IN (?)", member_accounts.id)

            life = 0
            life_amount = 0
            account_transactions.where("transacted_at <= ?", @as_of).order("transacted_at ASC").each do |at|
              if at.transaction_type == "withdraw"
                life = ((life_amount < 0 ? 0 : life_amount) - (at.amount < 0 ? 0 : at.amount))
              elsif at.transaction_type == "deposit" || at.transaction_type == "interest"
                life = (life_amount + at.amount).abs
              end
              life_amount = life
            end
                
            if index == 0
              sheet.add_row [
                  member.identification_number,
                  member.full_name_titleize,
                  member.insurance_date_resigned,
                  member.data.with_indifferent_access[:recognition_date].try(:to_date),
                  value,
                  "weekly",
                  20,
                  "",
                  life_amount,
                  "",
                  life_amount/2,
                  "",
                ], style: [nil, nil, date_format_cell,date_format_cell,currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
              else
                sheet.add_row [
                  member.identification_number,
                  member.full_name_titleize,
                  member.insurance_date_resigned,
                  member.data.with_indifferent_access[:recognition_date].try(:to_date),
                  value,
                  "weekly",
                  20,
                  "",
                  life_amount,
                  "",
                  life_amount/2,
                  "",
                ], style: [nil, nil, date_format_cell, date_format_cell,currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil, currency_cell_right, nil]
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
                ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  date_format_cell, currency_cell_right, nil, nil, nil, currency_cell_right, nil, date_format_cell, nil]
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
                ], style: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  date_format_cell, currency_cell_right, nil, nil, nil, currency_cell_right, nil, date_format_cell, nil]
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
