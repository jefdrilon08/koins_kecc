module Pages
  class GenerateDailyReportInsuranceAccountStatus
    def initialize(branch:)
      @branch                         = branch
      @centers                        = Center.where(branch_id: @branch).order("name ASC") 
      @p                              = Axlsx::Package.new
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

          
          sheet.add_row [
          "Member",
          "Recognition Date",
          "Member Status",
          "Insurance Status",
          "Center", 
          "Length of Membership", 
          "Certificate Number", 
          "RF",
          "Coverage Date", 
          "Number of Weeks Past Due", 
          "Amount Past Due", 
          "Status", 
          "LIF",
          "Coverage Date", 
          "Number of Weeks Past Due", 
          "Amount Past Due", 
          "Status"], 
          style: label_cell

          @centers.order("name ASC").each do |center|

            sheet.add_row []

            sheet.add_row [
                    center.name
                  ],
            style: label_cell

            @members = Member.active.where(center_id: center.id).order("last_name ASC")
            @members.each_with_index do |member, index|
              recognition_date  = member.recognition_date
              current_date = Date.today
              
              if recognition_date.present?
                #compute LIF
                lif_default = 15
                lif_account = MemberAccount.where(account_subtype: "Life Insurance Fund", member_id: member.id).sum(:balance)
                lif_coverage = (recognition_date + (lif_account / lif_default).weeks).strftime("%Y-%m-%d")
                
                lif_num_days   = (current_date - recognition_date).to_i
                lif_num_weeks  = (lif_num_days / 7).to_i + 1
                
                lif_insured_amount    = lif_num_weeks  * lif_default
                lif_amt_past_due      = (lif_account - lif_insured_amount).to_i * -1
                lif_num_weeks_past_due  = (lif_amt_past_due / lif_default)
                
                if lif_account.to_i > lif_insured_amount.to_i
                  lif_status = "advanced"
                elsif lif_account.to_i < lif_insured_amount.to_i
                  lif_status  = "past due"
                else
                  lif_status = "normal"
                end

                #compute RF
                rf_default = 5
                rf_account  = MemberAccount.where(account_subtype: "Retirement Fund", member_id: member.id).sum(:balance)
                rf_coverage = (recognition_date + (rf_account / rf_default).weeks).strftime("%Y-%m-%d")

                rf_num_days   = (current_date - recognition_date).to_i
                rf_num_weeks  = (rf_num_days / 7).to_i + 1

                rf_insured_amount    = rf_num_weeks  * rf_default
                rf_amt_past_due      = (rf_account - rf_insured_amount).to_i * -1
                rf_num_weeks_past_due  = (rf_amt_past_due / rf_default)

                if rf_account.to_i > rf_insured_amount.to_i
                  rf_status = "advanced"
                elsif rf_account.to_i < rf_insured_amount.to_i
                  rf_status  = "past due"
                else
                  rf_status = "normal"
                end

                if index == 0

                  sheet.add_row [
                    member.full_name,
                    member.data['recognition_date'],
                    member.status,
                    member.insurance_status,
                    member.center.name,
                    member.length_of_stay,
                    member.identification_number,
                    rf_account,
                    rf_coverage,
                    rf_num_weeks_past_due,
                    rf_amt_past_due,
                    rf_status,
                    lif_account,
                    lif_coverage,
                    lif_num_weeks_past_due,
                    lif_amt_past_due,
                    lif_status
                    ]
                else
                  sheet.add_row [
                    member.full_name,
                    member.data['recognition_date'],
                    member.status,
                    member.insurance_status,
                    member.center.name,
                    member.length_of_stay,
                    member.identification_number,
                    rf_account,
                    rf_coverage,
                    rf_num_weeks_past_due,
                    rf_amt_past_due,
                    rf_status,
                    lif_account,
                    lif_coverage,
                    lif_num_weeks_past_due,
                    lif_amt_past_due,
                    lif_status
                  ]
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
