module Reports
  class GenerateClaimsBlipReportExcel
    def initialize(branch:, type_of_insurance_policy:, classification_of_insured:, start_date:, end_date:, category_of_cause_of_death_tpd_accident:)
      @type_of_insurance_policy = type_of_insurance_policy
      @category_of_cause_of_death_tpd_accident = category_of_cause_of_death_tpd_accident
      @classification_of_insured = classification_of_insured
      @start_date = start_date
      @end_date = end_date
      @branch = branch

      if @branch.present? && @type_of_insurance_policy.present? && @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'type_of_insurance_policy' = ? AND data->>'classification_of_insured' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @classification_of_insured, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'classification_of_insured' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @branch, @classification_of_insured, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'type_of_insurance_policy' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @classification_of_insured.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'type_of_insurance_policy' = ? AND data->>'classification_of_insured' = ? AND claim_type = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @classification_of_insured, "BLIP").order("date_prepared DESC")  
      elsif @type_of_insurance_policy.present? && @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'type_of_insurance_policy' = ? AND data->>'classification_of_insured' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @type_of_insurance_policy, @classification_of_insured, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @branch, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @classification_of_insured.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'classification_of_insured' = ? AND claim_type = ?", @start_date, @end_date, @branch, @classification_of_insured, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND data->>'type_of_insurance_policy' = ? AND claim_type = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, "BLIP").order("date_prepared DESC") 
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'classification_of_insured' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @classification_of_insured, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'classification_of_insured' = ? AND data->>'type_of_insurance_policy' = ? AND claim_type = ?", @start_date, @end_date, @classification_of_insured, @type_of_insurance_policy, "BLIP").order("date_prepared DESC")
      elsif @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'type_of_insurance_policy' = ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")    
      elsif @branch.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND branch_id = ? AND claim_type = ?", @start_date, @end_date, @branch, "BLIP").order("date_prepared DESC")
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'classification_of_insured' = ? AND claim_type = ?", @start_date, @end_date, @classification_of_insured, "BLIP").order("date_prepared DESC")
      elsif @type_of_insurance_policy.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'type_of_insurance_policy' = ? AND claim_type = ?", @start_date, @end_date, @type_of_insurance_policy, "BLIP").order("date_prepared DESC")
      elsif @category_of_cause_of_death_tpd_accident.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @start_date, @end_date, @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC") 
      elsif @branch.present? && @classification_of_insured.present?
        @claims = Claim.where("data->>'classification_of_insured' = ? AND branch_id = ? AND claim_type = ?", @classification_of_insured, @branch, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("data->>'category_of_cause_of_death_tpd_accident' = ? AND branch_id = ? AND claim_type = ?", @category_of_cause_of_death_tpd_accident, @branch, "BLIP").order("date_prepared DESC")
      elsif @branch.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("data->>'type_of_insurance_policy' = ? AND branch_id = ? AND claim_type = ?", @type_of_insurance_policy, @branch, "BLIP").order("date_prepared DESC")          
      elsif @start_date.present? && @end_date.present?
        @claims = Claim.where("date_prepared >= ? AND date_prepared <= ? AND claim_type = ?", @start_date, @end_date, "BLIP").order("date_prepared DESC")
      elsif @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("data->>'category_of_cause_of_death_tpd_accident' = ? AND claim_type = ?", @category_of_cause_of_death_tpd_accident, "BLIP").order("date_prepared DESC")
      elsif @type_of_insurance_policy.present?
        @claims = Claim.where("data->>'type_of_insurance_policy' = ? AND claim_type = ?", @type_of_insurance_policy, "BLIP").order("date_prepared DESC")
      elsif @classification_of_insured.present?
        @claims = Claim.where("data->>'classification_of_insured' = ? AND claim_type = ?", @classification_of_insured, "BLIP").order("date_prepared DESC")      
      else  
        @claims = Claim.where(claim_type: 'BLIP').order("date_prepared DESC")
      end

      @p        = Axlsx::Package.new

      @total_equity_value = 0.00
      @total_retirement_fund = 0.00
      @total_face_amount = 0.00
      @total_benefit_payable = 0.00
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

          sheet.add_row [
            "CLAIMS REPORT (BLIP)"
            ],style: header
          
          sheet.add_row []
          
          sheet.add_row [ 
            "Date",
            "Branch",
            "Name of Member",
            "Policy Number",
            "Type of Insurance Policy",
            "Name of Insured",
            "Classification of Insured",
            "Beneficiary",
            "Date of Birth",
            "Age",
            "Sex",
            "Date of Policy Issue",
            "Face Amount",
            "Arrears",
            "Date of Death/TPD",
            "Death date was reported",
            "Date Paid",
            "Cause of Death/TPD/MVAH",
            "Category of Cause of Death/TPD/MVAH",
            "Benefit Payable",
            "Equity Value (LIFE)",
            "Retirement Fund (RF)",
            "Length of Membership",
            "Prepared by"
          ], style: header

          @claims.each do |claim|
            sheet.add_row [
                claim.date_prepared,
                claim.branch.name,
                claim.member.full_name,
                claim.data["policy_number"],
                claim.data["type_of_insurance_policy"],
                claim.data["name_of_insured"],
                claim.data["classification_of_insured"],
                claim.data["beneficiary"],
                claim.data["date_of_birth"].try(:to_date).try(:strftime, "%b %d, %Y"),
                claim.data["age"],
                claim.data["gender"],
                claim.data["date_of_policy_issue"].try(:to_date).try(:strftime, "%b %d, %Y"),
                claim.data["face_amount"],
                claim.data["arrears"],
                claim.data["date_of_death_tpd_accident"].try(:to_date).try(:strftime, "%b %d, %Y"),
                claim.date_prepared,
                claim.date_prepared,
                claim.data["cause_of_death_tpd_accident"],
                claim.data["category_of_cause_of_death_tpd_accident"],
                claim.data["face_amount"],
                claim.data["equity_value"],
                claim.data["retirement_fund"],
                claim.data["length_of_stay"],
                claim.prepared_by
              ], style: [date_format_cell, nil, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, date_format_cell, currency_cell_right, currency_cell_right, date_format_cell, date_format_cell, date_format_cell, nil, nil, currency_cell_right, currency_cell_right, currency_cell_right, nil, nil]

            @total_equity_value = @total_equity_value + claim.data["equity_value"].to_i
            @total_retirement_fund = @total_retirement_fund + claim.data["retirement_fund"].to_i
            @total_face_amount = @total_face_amount + claim.data["face_amount"].to_i
            @total_benefit_payable = @total_benefit_payable + claim.data["face_amount"].to_i
          end

          sheet.add_row [
            "TOTAL",
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
            @total_face_amount,
            "",
            "",
            "",
            "",
            "",
            "",
            @total_face_amount,
            @total_equity_value,
            @total_retirement_fund,
            "",
            ""
          ], style: [header_cells, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, currency_cell_right_bold, nil, nil, nil, nil, nil, nil, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, nil, nil]

        end
      end
      @p
    end
  end
end
