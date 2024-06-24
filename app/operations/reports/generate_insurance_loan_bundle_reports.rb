module Reports
  class GenerateInsuranceLoanBundleReports
    def initialize(branch:, start_date:, end_date:, status:)
      @branch_id              = branch
      @start_date             = start_date.try(:to_date)
      @start_date_query       = start_date
      @end_date               = end_date.try(:to_date)
      @end_date_query         = end_date
      @status                 = status

      @all_kok = InsuranceLoanBundleEnrollment.all
      @kok = []

      if @branch_id.present? && @start_date.present? && @end_date.present? && @status.present?
        sql_query = <<-SQL
          SELECT
            id,
            status,
            date_approved,
            record
          FROM
          insurance_loan_bundle_enrollments,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
            AND (record->'kok_data'->>'effectivity_date')::date >= '#{@start_date_query}'
            AND (record->'kok_data'->>'effectivity_date')::date <= '#{@end_date_query}'
          ORDER BY
            record->'kok_data'->>'effectivity_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        kok = query.map do |row|
          kok_records_last = InsuranceLoanBundleEnrollment.find(row['id']).records_last
          kok_status = row['status']
          kok_date_approved = row['date_approved']
          {
            'record' => kok_records_last,
            'status' => kok_status,
            'date_approved' => kok_date_approved
          }
        end
        @query_kok = kok
      elsif @branch_id.present? && @status.present?
        sql_query = <<-SQL
          SELECT
            id,
            status,
            date_approved,
            record
          FROM
          insurance_loan_bundle_enrollments,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
          ORDER BY
            record->'kok_data'->>'effectivity_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        kok = query.map do |row|
          kok_records_last = InsuranceLoanBundleEnrollment.find(row['id']).records_last
          kok_status = row['status']
          kok_date_approved = row['date_approved']
          {
            'record' => kok_records_last,
            'status' => kok_status,
            'date_approved' => kok_date_approved
          }
        end
        @query_kok = kok
      elsif @branch_id.present?
        sql_query = <<-SQL
          SELECT
            id,
            status,
            date_approved,
            record
          FROM
          insurance_loan_bundle_enrollments,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
          ORDER BY
            record->'kok_data'->>'effectivity_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        kok = query.map do |row|
          kok_records_last = InsuranceLoanBundleEnrollment.find(row['id']).records_last
          kok_status = row['status']
          kok_date_approved = row['date_approved']
          {
            'record' => kok_records_last,
            'status' => kok_status,
            'date_approved' => kok_date_approved
          }
        end
        @query_kok = kok
      end
      @p = Axlsx::Package.new
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
            right_aligned_cell = wb.styles.add_style alignment: { horizontal: :right }, font_name: "Calibri"
            underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
            header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
            date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
            default_cell = wb.styles.add_style font_name: "Calibri"
            premium_total = 0
            member_count = 0

            sheet.add_row ["KASAGANA-KA KOK DECLARATION"], style: title_cell
            sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
            sheet.add_row []

            sheet.add_row [
              "Date Approved",
              "Status",
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


            @query_kok.each do |kok|
              premium_total += kok['record']['kok_data']['premium_coverage'].to_i
              member_count += 1

              sheet.add_row [
                kok['date_approved'].try(:to_date).try(:strftime, "%b %d, %Y"),
                kok['status'],
                kok['record']['kok_data']['plan_type'],
                kok['record']['kok_data']['plan_category'],
                kok['record']['kok_data']['partner'],
                kok['record']['kok_data']['policy_no'],
                kok['record']['kok_data']['effectivity_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                kok['record']['kok_data']['maturity_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                kok['record']['kok_data']['client_type'],
                kok['record']['kok_data']['first_name'],
                kok['record']['kok_data']['middle_name'],
                kok['record']['kok_data']['last_name'],
                kok['record']['kok_data']['address'],
                kok['record']['kok_data']['gender'],
                kok['record']['kok_data']['enrolled_status'],
                kok['record']['kok_data']['civil_status'],
                kok['record']['kok_data']['birth_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                kok['record']['kok_data']['age'].to_i,
                kok['record']['kok_data']['premium_coverage'],
                kok['record']['kok_data']['mobile_no'],
                kok['record']['kok_data']['membership_date'],
                kok['record']['kok_data']['benif_fname'],
                kok['record']['kok_data']['benif_mname'],
                kok['record']['kok_data']['benif_lname'],
                kok['record']['kok_data']['benif_birth_date'],
                kok['record']['kok_data']['benif_gender'],
                kok['record']['kok_data']['benif_relationship']
              ], style: [left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell]
            end

            sheet.add_row []
            sheet.add_row []
            sheet.add_row []
            sheet.add_row ["Premium Total : ", premium_total], style: [right_aligned_cell, title_cell]
            sheet.add_row ["Member Count : ", member_count], style: [right_aligned_cell, title_cell]
          end
        end
        @p
    end
  end
end
