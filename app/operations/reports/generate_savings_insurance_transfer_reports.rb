module Reports
  class GenerateSavingsInsuranceTransferReports 
     if Settings.activate_microinsurance 
      def initialize(branch:, start_date:, end_date:, insurance_subtype:, payment_subtype:, status:)
        @start_date = start_date.try(:to_date) 
        @end_date = end_date.try(:to_date) 
        @branch_id = branch
        @insurance_subtype = insurance_subtype
        @payment_subtype = payment_subtype 
        @status = status

        if @insurance_subtype == "K-BENTE" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @payment_subtype.present?
          @kbente = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'payment_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @payment_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "K-BENTE" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present?
          @kbente = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "K-KALINGA" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @payment_subtype.present?
          @kkalinga = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'payment_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @payment_subtype, @branch_id, @status).order("collection_date DESC") 
        elsif @insurance_subtype == "K-KALINGA" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? 
          @kkalinga = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC") 
        elsif @insurance_subtype == "Hospital Income Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @payment_subtype.present?
          @hiip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'payment_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @payment_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Hospital Income Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present?
          @hiip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Credit Life Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @payment_subtype.present?
          @clip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'payment_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @payment_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Credit Life Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present?
          @clip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ?", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")  
        else
          puts "not valid"
        end
      @p        = Axlsx::Package.new
      end
      
    else
      def initialize(branch:, start_date:, end_date:, insurance_subtype:, savings_subtype:, status:)
        @start_date = start_date.try(:to_date) 
        @end_date = end_date.try(:to_date) 
        @branch_id = branch
        @insurance_subtype = insurance_subtype
        @savings_subtype = savings_subtype
        @status = status
        
        if @insurance_subtype == "K-BENTE" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @savings_subtype.present?
          @kbente = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'savings_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @savings_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "K-BENTE" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present?
          @kbente = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "K-KALINGA" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @savings_subtype.present?
          @kkalinga = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'savings_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @savings_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "K-KALINGA" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? 
          @kkalinga = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Hospital Income Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @savings_subtype.present?
          @hiip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'savings_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @savings_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Hospital Income Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present?
          @hiip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Credit Life Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? and @savings_subtype.present?
          @clip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND  data ->> 'savings_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @savings_subtype, @branch_id, @status).order("collection_date DESC")
        elsif @insurance_subtype == "Credit Life Insurance Plan" and @start_date.present? and @end_date.present? and @branch_id.present? and @insurance_subtype.present? 
          @clip = SavingsInsuranceTransferCollection.where("collection_date >= ? AND collection_date <= ? AND  data ->> 'insurance_subtype' = ? AND branch_id = ? AND status = ? ", @start_date, @end_date,  @insurance_subtype, @branch_id, @status).order("collection_date DESC")     
        else
          puts "not valid"
        end
        @p        = Axlsx::Package.new
      end
    end

    def execute!
      if @insurance_subtype == "K-BENTE"
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
            sheet.add_row ["KASAGANA-KA K-BENTE DECLARATION"], style: title_cell
            sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
            sheet.add_row []
            
            sheet.add_row [ 
              "AGE",
              "NAME OF INSURED",
              "BIRTHDATE",
              "GENDER",
              "STATUS",
              "ADDRESS",
              "BRANCH",
              "EFFECTITVITY DATE",
              "PREMIUM",
              "BENEFICIARY",
              "RELATIONSHIP",
              "DATE PREPARED",
              "DATE APPROVED",
              
            ], style: header
            @kbente.each do |kbente|
              kbente[:data]["records"].each_with_index do |o, index|
                sheet.add_row [
                  o["kbente_data"]["beneficiary_age"].to_i,
                  o["kbente_data"]["kbente_beneficiary_name"],
                  o["kbente_data"]["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kbente_data"]["gender"],
                  o["kbente_data"]["status"],
                  o["kbente_data"]["address"],
                  kbente[:data]["accounting_entry"]["branch"],
                  kbente.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["amount"],
                  o["member"]["first_name"] + " " + o["member"]["middle_name"] + " , " + o["member"]["last_name"],
                  o["kbente_data"]["relationship"],
                  o["kbente_data"]["effectivity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kbente.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
                  
                ], style: [ left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, currency_cell_right, left_aligned_cell, left_aligned_cell, date_format_cell, date_format_cell]
              end
            end
          end
        end
        @p
      
      elsif @insurance_subtype == "K-KALINGA"
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
            sheet.add_row ["KASAGANA-KA KALINGA DECLARATION"], style: title_cell
            sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
            sheet.add_row []
            
            sheet.add_row [ 
              "Agent",
              "OR DATE",
              "OR#",
              "CENTER",
              "AGE",
              "Name of Insured",
              "Birthdate",
              "GENDER",
              "STATUS",
              "ADDRESS",
              "BRANCH",
              "EFFECTITVITY DATE",
              "POC No.",
              "PREMIUM",
              "BENEFICIARY",
              "RELATIONSHIP",
              "DATE PREPARED",
              "DATE APPROVED"
            ], style: header
            @kkalinga.each do |kkalinga|
              kkalinga[:data]["records"].each_with_index do |o, index|
                sheet.add_row [
                  "",
                  "",
                  "",
                  kkalinga.center.name,
                  o["kkalinga_data"]["kkalinga_beneficiary_age"].to_i,
                  o["kkalinga_data"]["kkalinga_name_of_insured"],
                  o["kkalinga_data"]["kkalinga_date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kkalinga_data"]["kkalinga_gender"],
                  o["kkalinga_data"]["kkalinga_status"],
                  o["kkalinga_data"]["kkalinga_address"],
                  kkalinga[:data]["accounting_entry"]["branch"],
                  o["kkalinga_data"]["kkalinga_effectivity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  # kkalinga.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kkalinga_data"]["poc_number"],
                  o["amount"],
                  o["member"]["first_name"] + " " + o["member"]["middle_name"] + " , " + o["member"]["last_name"],
                  o["kkalinga_data"]["kkalinga_relationship"],
                  o["kkalinga_data"]["kkalinga_effectivity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kkalinga.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
                  
                ], style: [ left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, currency_cell_right, left_aligned_cell, left_aligned_cell, date_format_cell, date_format_cell]
              end
            end
          end
        end
        @p
      
    elsif @insurance_subtype == "Credit Life Insurance Plan"
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
            sheet.add_row ["KASAGANA-KA CLIP DECLARATION"], style: title_cell
            sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
            sheet.add_row []
            
            sheet.add_row [ 
              "Branch",
              "Center",
              "Member ID Number",
              "Policy Number",
              "Policy Code",
              "Name of Insured",
              "Date of Loan",
              "Amount of Loan",
              "Term of Loan",
              "Maturity Date of Loan",
              "Gross Premium"
            ], style: header
            @clip.each do |clip|
              clip[:data]["records"].each_with_index do |o, index|
                sheet.add_row [
                  clip.branch.name,
                  clip.center.name,
                  # o["member"]["id"],
                  Member.find(o["member"]["id"]).identification_number,
                  o["clip_data"]["clip_number"],
                  o["clip_data"]["clip_number"],
                  # o["member"]["first_name"] + " " + o["member"]["middle_name"] + " , " + o["member"]["last_name"],
                  Member.find(o["member"]["id"]).full_name,
                  o["clip_data"]["effective_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["clip_data"]["principal"],
                  o["clip_data"]["num_installments"],
                  o["clip_data"]["maturity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["amount"]
                  
                ], style: [ left_aligned_cell, left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell,date_format_cell,left_aligned_cell,left_aligned_cell,date_format_cell,left_aligned_cell]
              end
            end
          end
        end
        @p

    elsif @insurance_subtype == "Hospital Income Insurance Plan"
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
          sheet.add_row ["HIIP Report"], style: title_cell
          sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
          sheet.add_row []
          
          sheet.add_row [ 
           "BRANCH NAME",
           "NAME OF ASSURED",
           "POLICY NUMBER",
           "CERTIFICATE NUMBER",
           "SUM ASSURED",
           "PREMIUM",
           "PREMIUM TAX",
           "DOCUMENTARY TAX",
           "AMOUNT COLLECTED",
           "OFFICIAL RECEIPT",
           "OR DATE/EFFECTIVITY DATE",
           "MATURITY DATE",
           "TOTAL COLLECTION"
          ], style: header
          @hiip.each do |hiip|
            hiip[:data]["records"].each_with_index do |o, index|
              sheet.add_row [
                hiip[:data]["accounting_entry"]["branch"],
                Member.find(o["member"]["id"]).full_name,
                # o["member"]["first_name"].try["member"]["first_name"] + " " + o["member"]["middle_name"] + " , " + o["member"]["last_name"],
                Member.find(o["member"]["id"]).identification_number,
                Member.find(o["member"]["id"]).identification_number,
                "6,000.00",
                o["amount"],
                "N/A",
                "N/A",
                o["amount"],
                "OFFICIAL RECEIPT",
                hiip.date_approved.try(:to_date).try(:strftime, "%b %d, %Y"),
                "",
                ""
              ], style: [ left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, currency_cell_right, left_aligned_cell, left_aligned_cell, currency_cell_right, left_aligned_cell, date_format_cell,  date_format_cell, left_aligned_cell]
            end
          end
        end
      end
      @p
    end
  end
  end
end
