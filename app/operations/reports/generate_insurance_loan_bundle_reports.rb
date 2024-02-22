module Reports
  class GenerateInsuranceLoanBundleReports 
 
    def initialize(branch:, start_date:, end_date:, status:)
      @start_date = start_date.try(:to_date) 
      @end_date = end_date.try(:to_date) 
      @branch_id = branch
      @status = status
      
      if  @start_date.present? and @end_date.present? and @branch_id.present?
        @kok = InsuranceLoanBundleEnrollment.where("collection_date >= ? AND collection_date <= ? AND branch_id = ? AND status = ? ", @start_date, @end_date, @branch_id, @status).order("collection_date DESC")
      elsif @branch_id.present?
        @kok = InsuranceLoanBundleEnrollment.where("branch_id = ? AND status = ? ", @branch_id, @status).order("collection_date DESC")
      else
        puts "not valid"
      end
      @p        = Axlsx::Package.new
    end

    def execute!
      
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
            sheet.add_row ["KASAGANA-KA KOK DECLARATION"], style: title_cell
            sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
            sheet.add_row []
            
            sheet.add_row [ 
              "PlanType",
              "PlanCategory",
              "Partner",
              "PolicyNo",
              "EffectivityDate",
              "MaturityDate",
              "ClientType",
              "FirstName",
              "MiddleName",
              "LastName",
              "Address",
              "Gender",
              "EnrolledStatus",
              "CivilStatus",
              "BirthDate",
              "Age",
              "PremiumCoverage",
              "MobileNo",
              "MembershipDate",
              "Benif_Fname",
              "Benif_Mname",
              "Benif_Lname",
              "Benif_BirthDate",
              "Benif_Gender",
              "Benif_Relationship"

            ], style: header
            @kok.each do |kok|
              kok[:data]["records"].each_with_index do |o, index|
                sheet.add_row [
                  o["kok_data"]["plan_type"],
                  o["kok_data"]["plan_category"],
                  o["kok_data"]["partner"],
                  o["kok_data"]["policy_no"],
                  o["kok_data"]["effectivity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kok_data"]["maturity_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kok_data"]["client_type"],
                  o["kok_data"]["first_name"],
                  o["kok_data"]["middle_name"],
                  o["kok_data"]["last_name"],
                  o["kok_data"]["address"],
                  o["kok_data"]["gender"],
                  o["kok_data"]["enrolled_status"],
                  o["kok_data"]["civil_status"],
                  o["kok_data"]["birth_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kok_data"]["age"].to_i,
                  o["kok_data"]["premium_coverage"],
                  o["kok_data"]["mobile_no"],
                  o["kok_data"]["membership_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kok_data"]["benif_fname"],
                  o["kok_data"]["benif_mname"],
                  o["kok_data"]["benif_lname"],
                  o["kok_data"]["benif_birth_date"].try(:to_date).try(:strftime, "%b %d, %Y"),
                  o["kok_data"]["benif_gender"],
                  o["kok_data"]["benif_relationship"]       
                  
                ], style: [ left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell, date_format_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell,                   date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell]
              end
            end
          end
        end
        @p
    end
  end
end
