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
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND type_of_insurance_policy = ? AND classification_of_insured = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @classification_of_insured, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @branch.present? && @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND classification_of_insured = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @branch, @classification_of_insured, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @branch.present? && @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND type_of_insurance_policy = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @branch.present? && @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @classification_of_insured.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND type_of_insurance_policy = ? AND classification_of_insured = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @classification_of_insured).order("created_at DESC")  
      elsif @type_of_insurance_policy.present? && @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND type_of_insurance_policy = ? AND classification_of_insured = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @type_of_insurance_policy, @classification_of_insured, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @branch, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @classification_of_insured.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND classification_of_insured = ?", @start_date, @end_date, @branch, @classification_of_insured).order("created_at DESC")
      elsif @branch.present? && @start_date.present? && @end_date.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ? AND type_of_insurance_policy = ?", @start_date, @end_date, @branch, @type_of_insurance_policy).order("created_at DESC") 
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND classification_of_insured = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @classification_of_insured, @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND classification_of_insured = ? AND type_of_insurance_policy = ?", @start_date, @end_date, @classification_of_insured, @type_of_insurance_policy).order("created_at DESC")
      elsif @type_of_insurance_policy.present? && @start_date.present? && @end_date.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND type_of_insurance_policy = ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @branch, @type_of_insurance_policy, @category_of_cause_of_death_tpd_accident).order("created_at DESC")    
      elsif @branch.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("created_at DESC")
      elsif @classification_of_insured.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND classification_of_insured = ?", @start_date, @end_date, @classification_of_insured).order("created_at DESC")
      elsif @type_of_insurance_policy.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND type_of_insurance_policy = ?", @start_date, @end_date, @type_of_insurance_policy).order("created_at DESC")
      elsif @category_of_cause_of_death_tpd_accident.present? && @start_date.present? && @end_date.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ? AND category_of_cause_of_death_tpd_accident = ?", @start_date, @end_date, @category_of_cause_of_death_tpd_accident).order("created_at DESC") 
      elsif @branch.present? && @classification_of_insured.present?
        @claims = Claim.where("classification_of_insured = ? AND branch_id = ?", @classification_of_insured, @branch).order("created_at DESC")
      elsif @branch.present? && @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("category_of_cause_of_death_tpd_accident = ? AND branch_id = ?", @category_of_cause_of_death_tpd_accident, @branch).order("created_at DESC")
      elsif @branch.present? && @type_of_insurance_policy.present?
        @claims = Claim.where("type_of_insurance_policy = ? AND branch_id = ?", @type_of_insurance_policy, @branch).order("created_at DESC")          
      elsif @start_date.present? && @end_date.present?
        @claims = Claim.where("created_at >= ? AND created_at <= ?", @start_date, @end_date).order("created_at DESC")
      elsif @category_of_cause_of_death_tpd_accident.present?
        @claims = Claim.where("category_of_cause_of_death_tpd_accident = ?", @category_of_cause_of_death_tpd_accident).order("created_at DESC")
      elsif @type_of_insurance_policy.present?
        @claims = Claim.where("type_of_insurance_policy = ?", @type_of_insurance_policy).order("created_at DESC")
      elsif @classification_of_insured.present?
        @claims = Claim.where("classification_of_insured = ?", @classification_of_insured).order("created_at DESC")      
      else  
        @claims = Claim.all.order("created_at DESC")
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
                claim.created_at.to_date,
                claim.branch.name,
                claim.member.full_name,
                claim.policy_number,
                claim.type_of_insurance_policy,
                claim.name_of_insured,
                claim.classification_of_insured,
                claim.beneficiary,
                claim.date_of_birth,
                claim.age,
                claim.gender,
                claim.date_of_policy_issue,
                claim.face_amount,
                claim.arrears,
                claim.date_of_death_tpd_accident,
                claim.created_at.to_date,
                claim.created_at.to_date,
                claim.cause_of_death_tpd_accident,
                claim.category_of_cause_of_death_tpd_accident,
                claim.face_amount,
                claim.equity_value,
                claim.retirement_fund,
                claim.length_of_stay,
                claim.prepared_by
              ], style: [date_format_cell, nil, nil, nil, nil, nil, nil, nil, date_format_cell, nil, nil, date_format_cell, currency_cell_right, currency_cell_right, date_format_cell, date_format_cell, date_format_cell, nil, nil, currency_cell_right, currency_cell_right, currency_cell_right, nil, nil]

            @total_equity_value = @total_equity_value + claim.equity_value
            @total_retirement_fund = @total_retirement_fund + claim.retirement_fund
            @total_face_amount = @total_face_amount + claim.face_amount
            @total_benefit_payable = @total_benefit_payable + claim.face_amount
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
