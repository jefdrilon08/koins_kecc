module ExcelReports
  class GenerateReportPodsClosing
    def initialize(config:)
      @config     = config
      @branch_id  = @config[:branch_id]
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @p = Axlsx::Package.new
    end

    def get_district_name(id)
      AdminBarangay.find_by(id: id)&.barangay_name || "Unknown"
    end

    def get_city_name(id)
      AdminMunicipality.find_by(id: id)&.municipality_name || "Unknown"
    end

    def get_province_name(id)
      AdminProvince.find_by(id: id)&.province_name || "Unknown"
    end

    def execute!
     
          @p.workbook do |wb|
            wb.add_worksheet do |sheet|
              header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
              title_cell = wb.styles.add_style b: true, font_name: "Calibri"
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

              sheet.add_row ["PODs Template"], style: title_cell
              sheet.add_row ["Institution" , "K-COOP"], style: title_cell
              sheet.add_row ["Cut Off Date" , "#{@report_date}"], style: title_cell
              sheet.add_row ["No. Of Clients"], style: title_cell
              sheet.add_row ["BEGIN"], style: title_cell

              # For header
              sheet.add_row [ 
              "ClientReference",
              "LastName",
              "FirstName",
              "MiddleName",
              "PreviousLastName",
              "Street",
              "BarangayDistrict",
              "CityMunicipality",
              "Province",
              "ZipCode",
              "BirthDate",
              "BirthPlace",
              "Gender",
              "CivilStatus",
              "ContactNo",
              "MothersMaidenFirstName",
              "MotherMaidenMiddleName",
              "MotherMaidenLastName",
              "IDType",
              "IDNo",
              "SSSNo",
              "GSISNo",
              "PhilHealthNo",
              "TINo",
              "LoanReference",
              "ContractType",
              "ContractPhase",
              "TransactionType",
              "LoanAmountDisbursed",
              "PrincipalBalance",
              "DateGranted",
              "DateDue",
              "InterestRate",
              "PayFreq",
              "Term",
              "Currency",
              "LoanPurpose",
              "PODType",
              "TotalLoanBalance",
              "ContractActualEndDate",
              "OverdueDays",
              "MonthlyPaymentAmount",
              "NoOfOutstandingPayments",
              "AmountOfLastPayment",
              "Remarks"
              ], style: header
               @loans = Loan.where("branch_id = ? and maturity_date >= ? and maturity_date <= ? and status= ?", "#{@branch_id}","#{@start_date}","#{@end_date}", "paid")
                @loans.each do |l|
                  @member       = Member.find(l.member_id)
                  @member_data  = @member.data.with_indifferent_access
                  @last_name    = @member.last_name
                  @first_name   = @member.first_name
                  @middle_name  = @member.middle_name
                  @address = {
                    street:   @member[:data]["address"]["street"],
                    # barangay: @member[:data]["address"]["district"],
                    # city:     @member[:data]["address"]["city"],
                    # province: @member[:data]["address"]["province"]
                    barangay: get_district_name(@member_data.dig("address", "district")),
                    city:     get_city_name(@member_data.dig("address", "city")),
                    province: get_province_name(@member_data.dig("address", "province"))
                  }

                  @street    = @address[:street]
                  @barangay  = @address[:barangay]
                  @city      = @address[:city]
                  @province  = @address[:province]
                  @birthdate = @member.date_of_birth
                  @place_of_birth = @member.place_of_birth
                  
                  case @member.gender
                    when "Female"
                      @gender = "F"
                    when "Male"
                      @gender = "M"
                  end

                  case @member.civil_status
                    when  'May Kinakasama' , 'Single' , 'single'
                      @civil_status = 1
                    when 'Kasal' , 'married'
                      @civil_status = 2
                    when 'Hiwalay' , 'separated'
                      @civil_status = 3
                    when 'Biyudo/a' , 'widowed'
                      @civil_status = 4
                    else 
                      @civil_status = ""
                  end

                    
                  @mobile_number       = @member.mobile_number                  
                  @mothers_first_name  = @member_data[:mothers_first_name]
                  @mothers_middle_name = @member_data[:mothers_middle_name]
                  @mothers_last_name   = @member_data[:mothers_last_name]
                  
                  @goverment_id = {
                    sss: @member_data[:government_identification_numbers]["sss_number"],
                    tin: @member_data[:government_identification_numbers]["tin_number"],
                    pag_ibig: @member_data[:government_identification_numbers]["pag_ibig_number"],
                    phil_health: @member_data[:government_identification_numbers]["phil_health_number"]
                  }

                  @pn_number = l[:pn_number]
                  @settings = Settings.loan_products.select{ |o| o.loan_product_id == l['loan_product_id']}.first.midas

                  if @settings.nil?
                    @contractType     = ""
                    @contractPhase    = ""
                    @transactionType  = "CL"
                    @loanPurpose      = ""
                  else
                    @contractType    = @settings.contract_type
                    @contractPhase   = @settings.contract_phase
                    @transactionType = "CL"
                    @loanPurpose     = @settings.loan_purpose
                  end


                  @interest_rate = (l.monthly_interest_rate * 12)*100
                  @total_loan_balance = (l[:principal_balance] + l[:interest_balance]).to_f.round(2)
                  @date_completed = l[:date_completed]
                  @amort = AmortizationScheduleEntry.where(loan_id: l.id).last
                  @last_loan_payment = AccountTransaction.where(subsidiary_id: l.id, status: "approved").order("transacted_at DESC").first




                  sheet.add_row [
                  @member["identification_number"],
                  @last_name,
                  @first_name,
                  @middle_name,
                  "",
                  @street,
                  @barangay,
                  @city,
                  @province,
                  "",
                  @birthdate,
                  @place_of_birth,
                  @gender,
                  @civil_status,
                  @mobile_number.to_s,
                  @mothers_first_name,
                  @mothers_middle_name,
                  @mothers_last_name,
                  "",
                  "",
                  @goverment_id[:sss],
                  "",
                  @goverment_id[:phil_health],
                  @goverment_id[:tin],
                  @pn_number,
                  @contractType,
                  @contractPhase,
                  @transactionType,
                  l[:principal],
                  l[:principal_balance],
                  l[:date_released],
                  l[:maturity_date],
                  @interest_rate,
                  l[:loan_term],
                  l[:num_installments],
                  "Php",
                  @loanPurpose,
                  "50-01",
                  @total_loan_balance,
                  @date_completed,
                  "0",
                  @amort.amount_due.to_f,
                  "0",
                  @last_loan_payment.amount.to_f

                  ],types: [ nil, nil , nil , nil ,nil, nil , nil, nil, nil , nil , nil , nil , nil , nil , :string , nil , nil , nil , nil , nil , :string , nil , :string , :string , :string]


                end
              sheet.add_row ["END"], style: title_cell
            end #end of sheet 
          end #end of wb
          @p  
    end
  end
end 
