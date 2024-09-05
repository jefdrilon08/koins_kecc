module ExcelReports
  class GenerateMemberRegistry
    def initialize(config:)
      @config     = config
      branch_id   = @config[:branch_id]
      @member      = Member.where("branch_id = ? and status NOT IN ('archived' , 'pending')", branch_id)
      @p          = Axlsx::Package.new
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

    def get_region_name(id)
      AdminAddress.find_by(id: id)&.region_name || "Unknown"
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

          sheet.add_row ["" , "Membership Number" , "Name of Member" ,"Tax Identification Number" , "I. INFORMATION ON MEMBERSHIP UPON ACCEPTANCE", "" , "" , "" , "" , "" , "" , "II. MEMBERS PROFILE" , "" , "" , "" , "" , "", "" , "" , "" , "" , "III. TERMINATION OF MEMBERSHIP"]
          sheet.merge_cells "A1:A4"
          sheet.merge_cells "B1:B4"
          sheet.merge_cells "C1:C4"
          sheet.merge_cells "D1:D4"
          sheet.merge_cells "E1:K1"
          sheet.merge_cells "L1:U1"
          sheet.merge_cells "V1:W2"

          sheet.add_row ["" , "" , "" , "" , "Date Accepted" , "BOD Resolution Number" , "TYPE/ KIND & MEMBERSHIP" , "" , "Initital Capital Subscription" , "" , "" , "Address" , "Date of Birth" , "Age" , "Gender" , "Civil Status" , "Highest Educational Attainment" , "Occupation / Income Source" , "Number of Dependents" , "Religious / Social Affiliation" , "Annual Income"]
          sheet.merge_cells "E2:E4"
          sheet.merge_cells "F2:F4"
          sheet.merge_cells "G2:H3"
          sheet.merge_cells "I2:K2"
          sheet.merge_cells "L2:L4"
          sheet.merge_cells "M2:M4"
          sheet.merge_cells "N2:N4"
          sheet.merge_cells "O2:O4"
          sheet.merge_cells "P2:P4"
          sheet.merge_cells "Q2:Q4"
          sheet.merge_cells "R2:R4"
          sheet.merge_cells "S2:S4"
          sheet.merge_cells "T2:T4"
          sheet.merge_cells "U2:U4"

          sheet.add_row ["" , "" , "" , "" , "" , "" , "" , "" , "Number of Shares Subscribed" , "Amount Subscribed" , "Initial Payment" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "DATE" , "BOD Resolution"]
          sheet.merge_cells "I3:I4"
          sheet.merge_cells "J3:J4"
          sheet.merge_cells "K3:K4"
          sheet.merge_cells "V3:V4"
          sheet.merge_cells "W3:W4"
          
          sheet.add_row ["" , "" , "" , "" , "" , "" , "Regular" , "Associate"]
          @member.each.with_index do |mem , i|
            i = i + 1
            mem_data = mem.data
            gov = mem_data['government_identification_numbers']
            tin_no    = gov['tin_number']
            get_address   = mem_data['address']
            street = get_address['street']
            # address =  "#{get_address['street']} #{get_address['district']} #{get_address['city']} #{get_address['region']} #{get_address['perovince']}"
            district_name = get_district_name(get_address['district'])
            city_name = get_city_name(get_address['city'])
            province_name = get_province_name(get_address['province'])
            region_name = get_region_name(get_address['region'])
            address = "#{street} #{district_name} #{city_name} #{province_name} #{region_name}"
            dependent = mem.legal_dependents.count
            if mem.status = 'resigned'
              res = mem.date_resigned
            else
              res = ''
            end
            sheet.add_row [i , mem.identification_number , mem.full_name , tin_no , mem.date_of_membership , "" , "" , "" , 4 , 400.00 , 100.00 , address , mem.date_of_birth , mem.age , mem.gender , mem.civil_status , "" , "" , dependent , mem.religion , "" , res]
          end    
        end
      end
      @p
    end
  end
end
 
