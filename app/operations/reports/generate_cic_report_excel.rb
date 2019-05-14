module Reports
  class GenerateCicReportExcel
    def initialize(start_date:, end_date:, provider_code:)
      @start_date = start_date
      @end_date   = end_date
      @provider_code = provider_code
      @members = Member.active.where("data ->>'recognition_date' <= ? AND data -> 'government_identification_numbers' ->> 'tin_number' != ? OR data ->>'recognition_date' <= ? AND data -> 'government_identification_numbers' ->> 'sss_number' != ?", @end_date.to_date, "", @end_date.to_date, "")
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

          # For header
          sheet.add_row [ 
            "HD",
            @provider_code,
            @end_date,
            "1",
            "0",
            "FOR THE MONTH OF #{@end_date.to_date.strftime('%m')}"
          ], 
          style: default_cell,
          types: [nil, :string, :string, nil, nil, nil]


          # For individual data info
          @members.each_with_index do |member, index|
            
            # for MRS or MR title 
            if member.gender == "Female" || member.gender == "female" || member.gender == "babae" || member.gender == "Babae"
              gender_title = 13
            elsif member.gender == "male" || member.gender == "Male" || member.gender == "lalaki" || member.gender == "Lalaki"
              gender_title = 10
            else
              gender_title = 13 
            end

            # For gender
            if member.gender == "Female" || member.gender == "female" || member.gender == "babae" || member.gender == "Babae"
              gender = "F"
            elsif member.gender == "male" || member.gender == "Male" || member.gender == "lalaki" || member.gender == "Lalaki"
              gender = "F"
            else
              gender = "F"
            end

            # For Civil Status
            if member.civil_status == "Single" || member.civil_status == "SINGLE" || member.civil_status == "single"
              civil_status = 1
            elsif member.civil_status == "Married" || member.civil_status == "married" || member.civil_status == "MARRIED" || member.civil_status == "kasal" || member.civil_status == "Kasal" || member.civil_status == "KASAL" || member.civil_status == "may kinakasama" || member.civil_status == "May Kinakasama" || member.civil_status == "MAY KINAKASAMA"
              civil_status = 2
            elsif member.civil_status == "Divorced" || member.civil_status == "DIVORCED" || member.civil_status == "divorced" || member.civil_status == "separated" || member.civil_status == "Separated" || member.civil_status == "SEPARATED" || member.civil_status == "hiwalay" || member.civil_status == "Hiwalay" || member.civil_status == "HIWALAY"
              civil_status = 3
            elsif member.civil_status == "widowed" || member.civil_status == "Widowed" || member.civil_status == "WIDOWED" || member.civil_status == "biyudo/a" || member.civil_status == "Biyudo/a" || member.civil_status == "BIYUDO/A"
              civil_status = 4  
            end

            # For government number
            if member.data['government_identification_numbers']['sss_number'].present?
              identification_number_type = 11
              id_number = member.data['government_identification_numbers']['sss_number'].split("-").join("").to_s
              if id_number.length == 10
                identification_number = id_number
              else
                identification_number = "Invalid"
              end
            elsif member.data['government_identification_numbers']['tin_number'].present?
              identification_number_type = 10
              id_number = member.data['government_identification_numbers']['tin_number'].split("-").join("").to_s
              if id_number.length >= 9 && id_number.length <= 12
                identification_number = id_number
              else 
                identification_number = "Invalid"
              end 
            else
              identification_number_type = ""
              identification_number = ""
            end

            if member.mobile_number.present?
              if member.mobile_number.length == 11
                contact_type = 3
                contact = member.mobile_number.split("-").join("").to_s
              else
                contact_type = 7
                contact = "nocontact@noemail.com"
              end  
            else
              contact_type = 7
              contact = "nocontact@noemail.com"
            end

            sheet.add_row [
              "ID",
              @provider_code,
              "",
              @end_date.to_date.strftime("%d%m%Y"),
              member.identification_number,
              gender_title,
              member.first_name.upcase,
              member.last_name.upcase,
              member.middle_name.upcase,
              "",
              "",
              "",
              gender,
              member.date_of_birth.strftime("%d%m%Y"),
              "",
              "PH",
              "PH",
              "1",
              civil_status,
              member.legal_dependents.count,
              "",
              member.data['spouse']['first_name'].try(:upcase),
              member.data['spouse']['last_name'].try(:upcase),
              member.data['spouse']['middle_name'].try(:upcase),
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "MI",
              "",
              member.data['address']['street'].upcase,
              "",
              "",
              member.data['address']['district'].upcase,
              member.data['address']['city'].upcase,
              "PH",
              "",
              "",
              "AI",
              "",
              member.data['address']['street'].upcase,
              "",
              "",
              member.data['address']['district'].upcase,
              member.data['address']['city'].upcase,
              "PH",
              "",
              "",
              identification_number_type,
              identification_number,
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
              "",
              "",
              "",
              "",
              "",
              "",
              contact_type,
              contact,
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
              "last_column",
            ], style: [ nil, nil ],
               types: [ nil, :string, nil, :string, nil, nil, nil, nil, nil, nil, 
                        nil, nil, nil, :string, nil, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, :string, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                        nil, nil, nil, nil, nil, nil, nil, nil, :string ]
          end

        # For utilities
          # N - Too new to be rated / Not Available
          # 0 - Paid as agreed / Current
          # 1 - 1-30 days delay
          # 2 - 31-60 days delay
          # 3 - 61-90 days delay
          # 4 - 91-180 days delay
          # 5 - 181-365 days delay
          # 6 - More than 1 year delay

          @members.each_with_index do |member, index|

            life_transaction               = "Life Insurance Fund"
            member_account                 = MemberAccount.where("member_id = ? AND account_subtype = ? ", member.id, life_transaction).first
            insurance_account_transactions = AccountTransaction.where("subsidiary_id = ?", member_account.id).order("transacted_at ASC")
            recognition_date               = member.data['recognition_date'].to_date
            current_date                   = @end_date.to_date

            latest_payment   = insurance_account_transactions.where("transacted_at <= ? ", @end_date).last
            current_balance  = latest_payment ? latest_payment.data['ending_balance'].to_i : 0.00

            if member_account.account_subtype == "Retirement Fund"
              default_periodic_payment = 5 
            elsif member_account.account_subtype == "Life Insurance Fund"
              default_periodic_payment = 15
            end

            num_days   = (current_date - recognition_date).to_i
            num_weeks  = (num_days / 7).to_i + 1
            insured_amount = num_weeks * default_periodic_payment.to_f
            latest_transaction_date  = latest_payment ? latest_payment.transacted_at : current_date
            amt_past_due          = (current_balance - insured_amount) * -1
            num_weeks_past_due    = (amt_past_due / default_periodic_payment).to_i

            # Code to compute all transactions amount
            life = 0.0
            life_amount = 0.0
            insurance_account_transactions.where("transacted_at >= ? AND transacted_at <= ?", @start_date, @end_date).each do |iat|
              if iat.transaction_type == "withdraw" || iat.transaction_type == "reversed" || iat.transaction_type == "fund_transfer_withdraw" || iat.transaction_type == "reverse_deposit"
                life = (life_amount - iat. ).abs
              elsif iat.transaction_type == "deposit" || iat.transaction_type == "fund_transfer_deposit" || iat.transaction_type == "reverse_withdraw"
                life = (life_amount + iat.amount).abs
              end
              life_amount = life
            end

            lif_past_due = insured_amount - current_balance
            if lif_past_due < 0
              lif_past_due = 0
            end

            num_of_days_past_due = num_weeks_past_due * 7
            if num_of_days_past_due <= 0
              over_due_days = 0
            elsif num_of_days_past_due > 1 && num_of_days_past_due <= 30
              over_due_days = 1
            elsif num_of_days_past_due > 30 && num_of_days_past_due <= 60
              over_due_days = 2
            elsif num_of_days_past_due > 60 && num_of_days_past_due <= 90
              over_due_days = 3
            elsif num_of_days_past_due > 90 && num_of_days_past_due <= 180
              over_due_days = 4
            elsif num_of_days_past_due > 180 && num_of_days_past_due <= 365
              over_due_days = 5
            elsif num_of_days_past_due > 365  
              over_due_days = 6
            end  

            if num_weeks_past_due < 0
              num_weeks_past_due = 0
            end

            sheet.add_row [
              "CS",
              @provider_code,
              "",
              @end_date.to_date.strftime("%d%m%Y"),
              member.identification_number,
              "B",
              member.identification_number,
              88,
              "AC",
              "",
              "PHP",
              "PHP",
              member.recognition_date.try(:to_date).strftime("%d%m%Y"),
              member.recognition_date.try(:to_date).strftime("%d%m%Y"),
              "",
              "",
              "",
              "M",
              # or Weekly (W)
              "CAS",
              "",
              "",
              # "<Billed Amount (LIF PAID CUR MONTH)>",
              life_amount,
              # "<Outstanding Balance (LIF -PAST DUE)>",
              lif_past_due,
              # "<Overdue Payments Number (LIF WKS DEFAULT)>",
              num_weeks_past_due,
              # "<Overdue Payments Amount (LIF -PAST DUE)>",
              lif_past_due,
              over_due_days,
              "",
              0,
              "F"

            ], style: [ nil, nil ],
               types: [ nil, :string, nil, :string, nil, nil, nil, nil, nil, nil, nil, nil, :string, :string ]
          end

          # Footer
          sheet.add_row [ 
            "FT",
            @provider_code,
            @end_date,
            "<< Number of records >>",
          ], style: default_cell
        end
      end
      
      @p
    end
  end
end
