module ExcelReports
  class GenerateReportBaris
    def initialize(config:)
      @config       = config
      branch_id     = @config[:branch_id]
      @rd           = @config[:report_date]
      @report_date  = @rd.to_date.strftime("%m/%d/%Y") 
      @data_store   = DataStore.where("meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ? AND meta->>'data_store_type' = ?", branch_id, @rd, "MANUAL_AGING").last
      @data_store_data = @data_store.data.with_indifferent_access
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

        sheet.add_row ["BARs Template"], style: title_cell
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
          "LoanPrincipal",
          "LoanBalance",
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

          @data_store_data[:records].each.with_index do |l|  
            mat_date = AmortizationScheduleEntry.where(loan_id: l['id']).order(:due_date).last.due_date
               
              if mat_date.to_date <= @rd.to_date
                member_rec = l['member']
                member     = Member.find(member_rec['id'])
                address    = member.data['address']
                mem        = member.data
                gov_id     = mem['government_identification_numbers']
                loan       = Loan.find(l['id'])

                # sett       = Settings.loan_products.select{ |o| o.loan_product_id == l['loan_product']['id']}.first.midas
                sett = Settings.loan_products.find { |o| o.loan_product_id == l['loan_product']['id'] }&.midas

                int_rate   = (loan.monthly_interest_rate*12)*100

                #PreviousLastName
                # Check for gender and set PreviousLastName accordingly
                if member.gender == 'Female' && member_rec['middle_name'].present?
                  previous_last_name = member_rec['middle_name']
                end

                #civil_status
                case member.civil_status
                when 'May Kinakasama' , 'Single' , 'single'
                  cs = 1
                when 'Kasal' , 'married'
                  cs = 2
                when 'Hiwalay' , 'separated'
                  cs = 3
                when 'Biyudo/a' , 'widowed'
                  cs = 4
                else
                  cs = ''
                end
                #GOV_ID
                sss_no =  gov_id['sss_number'].to_s.gsub(/[^0-9]/ ,"")
                if sss_no.length == 10
                  sss = sss_no
                else
                  sss = ""
                end
                phil_health_no = gov_id['phil_health_number'].to_s.gsub(/[^0-9]/ ,"")
                if phil_health_no.length == 12
                   phil_health = phil_health_no
                else
                   phil_health = ""
                end
                tin_no =  gov_id['tin_number'].to_s.gsub(/[^0-9]/ ,"")
                if tin_no.length == 12 || tin_no.length == 9
                   tin = tin_no
                else
                   tin = ""
                end


                #contract_type
                if sett.nil?
                  c_type  = ""
                  c_phase = ""
                  t_type  = ""
                  l_purpose = ""
                else
                  c_type  = sett.contract_type
                  c_phase = sett.contract_phase
                  t_type  = sett.transaction_type
                  l_purpose = sett.loan_purpose
                end
                #pod_type
                if l['maturity_date'].to_date == mat_date.to_date
                  pod_type = "50-01"
                else
                  pod_type = "54-02"
                end
                #overdue
                overdue = l['num_days_par']
                case overdue
                when 0
                  od = 0
                when 1..30
                  od = 1
                when 31..60
                  od = 2
                when 61..90
                  od = 3
                when 91..180
                  od = 4
                when 181..365
                  od = 5
                else  
                  od = 6
                end
                #m_payment
                m_payment = AmortizationScheduleEntry.where(loan_id: l['id']).order(:due_date).first.amount_due * 4
                #no_outstanding_payment
                last_at = AccountTransaction.where("subsidiary_id = ? and transacted_at <= ? and transaction_type = 'loan_payment' and amount > 0" , l['id'] , @rd).order(:transacted_at).last
                if last_at.nil?
                  last_date = @rd
                  last_payment = 0
                else
                  last_date = last_at.data['amort_entries'].last['due_date']                
                  last_payment = last_at.amount.to_i
                end
                nop = AmortizationScheduleEntry.where("loan_id = ? and due_date >?",l[:id] , last_date).count
                #body
                sheet.add_row [
                  member_rec['identification_number'],
                  member_rec['last_name'],
                  member_rec['first_name'],
                  member_rec['middle_name'],
                  previous_last_name,
                  address['street'],
                  # address['district'],
                  # address['city'],
                  # address['province'],
                  get_district_name(address['district']),
                  get_city_name(address['city']),
                  get_province_name(address['province']),
                  "",
                  member.date_of_birth,
                  member.place_of_birth,
                  member.gender[0],
                  cs,
                  member.mobile_number.to_s,
                  mem['mothers_first_name'],
                  mem['mothers_middle_name'],
                  mem['mothers_last_name'],
                  "",
                  "",
                  sss,
                  "",
                  phil_health,
                  tin,
                  l['pn_number'],
                  c_type,
                  c_phase,
                  t_type,
                  l['principal'],
                  l['overall_principal_balance'],
                  l['date_released'],
                  mat_date,
                  int_rate,
                  loan.term,
                  loan.num_installments,
                  "Php",
                  l_purpose,
                  pod_type,
                  l['overall_balance'],
                  mat_date,
                  od,
                  m_payment,
                  nop,
                  last_payment
                ], types: [ nil, nil , nil , nil , nil , nil, nil, nil , nil , nil , nil , nil , nil , :string , nil , nil , nil , nil , nil , :string , nil , :string , :string , :string]
              end
          end
        sheet.add_row ["END"], style: title_cell
       end
      end
     
      @p
    end
 
  end
end 
