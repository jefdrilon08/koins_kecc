module Reports
  class GenerateInsuranceLoanBundleReports

    def initialize(branch:, start_date:, end_date:, status:)
      # def initialize(branch:, status:)

      @branch_id              = branch
      @start_date             = start_date.try(:to_date)
      @start_date_query       = start_date
      @end_date               = end_date.try(:to_date)
      @end_date_query         = end_date
      @status                 = status

      # raise @end_date.inspect

      @all_kok = InsuranceLoanBundleEnrollment.all
      @kok = []

      if @branch_id.present? && @start_date.present? && @end_date.present? && @status.present?
        #raw from sql
        sql_query = <<-SQL
          SELECT
            record
          FROM
          insurance_loan_bundle_enrollments,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
            AND (record->'kok_data'->>'effectivity_date')::date >= '#{@start_date_query}'
            AND (record->'kok_data'->>'effectivity_date')::date <= '#{@end_date_query}'
        SQL
        query = ActiveRecord::Base.connection.execute(sql_query)
        # raise query.to_json.inspect
        #convertion
        kok = query.map do |row|
          record = row['record']
          parsed_record = JSON.parse(record)
          member_data = parsed_record['member']
          kok_data = parsed_record['kok_data']
            {
              'member' => member_data,
              'kok_data' => kok_data
            }
        end
        @query_kok = kok
      elsif @branch_id.present? && @status.present?
        data = @all_kok.where("branch_id = ? AND status = ?",@branch_id, @status)
        data.each do |k|
          kok_data = k.records_last
          @kok << kok_data
        end
        # raise @kok.inspect
      elsif @branch_id.present?
        data = @all_kok.where("branch_id = ?",@branch_id)
        data.each do |k|
          kok_data = k.records_last
            @kok << kok_data
        end
      else
        @kok = @all_kok
      end


      # raise @kok.inspect
      # if  @start_date.present? and @end_date.present? and @branch_id.present?
      #   @kok = InsuranceLoanBundleEnrollment.where("collection_date >= ? AND collection_date <= ? AND branch_id = ? AND status = ? ", @start_date, @end_date, @branch_id, @status).order("collection_date DESC")
      # elsif @branch_id.present?
      #   @kok = InsuranceLoanBundleEnrollment.where("branch_id = ? AND status = ? ", @branch_id, @status).order("collection_date DESC")
      # else
      #   puts "not valid"
      # end
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
            underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
            header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
            date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
            default_cell = wb.styles.add_style font_name: "Calibri"
            sheet.add_row ["KASAGANA-KA KOK DECLARATION"], style: title_cell
            # sheet.add_row ["For the period of: #{@start_date} - #{@end_date}"], style: title_cell
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


            if @kok.present?
              @kok.each do |kok|
                sheet.add_row [
                  kok[:kok_data][:plan_type],
                  kok[:kok_data][:plan_category],
                  kok[:kok_data][:partner],
                  kok[:kok_data][:policy_no],
                  kok[:kok_data][:effectivity_date].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok[:kok_data][:maturity_date].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok[:kok_data][:client_type],
                  kok[:kok_data][:first_name],
                  kok[:kok_data][:middle_name],
                  kok[:kok_data][:last_name],
                  kok[:kok_data][:address],
                  kok[:kok_data][:gender],
                  kok[:kok_data][:enrolled_status],
                  kok[:kok_data][:civil_status],
                  kok[:kok_data][:birth_date].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok[:kok_data][:age].to_i,
                  kok[:kok_data][:premium_coverage],
                  kok[:kok_data][:mobile_no],
                  kok[:kok_data][:membership_date].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok[:kok_data][:benif_fname],
                  kok[:kok_data][:benif_mname],
                  kok[:kok_data][:benif_lname],
                  kok[:kok_data][:benif_birth_date].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok[:kok_data][:benif_gender],
                  kok[:kok_data][:benif_relationship]
                ], style: [ left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell, date_format_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell]
              end
            else
              # raise @query_kok.inspect
              @query_kok.each do |kok|
                sheet.add_row [
                  kok['kok_data']['plan_type'],
                  kok['kok_data']['plan_category'],
                  kok['kok_data']['partner'],
                  kok['kok_data']['policy_no'],
                  kok['kok_data']['effectivity_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok['kok_data']['maturity_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok['kok_data']['client_type'],
                  kok['kok_data']['first_name'],
                  kok['kok_data']['middle_name'],
                  kok['kok_data']['last_name'],
                  kok['kok_data']['address'],
                  kok['kok_data']['gender'],
                  kok['kok_data']['enrolled_status'],
                  kok['kok_data']['civil_status'],
                  kok['kok_data']['birth_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok['kok_data']['age'].to_i,
                  kok['kok_data']['premium_coverage'],
                  kok['kok_data']['mobile_no'],
                  kok['kok_data']['membership_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok['kok_data']['benif_fname'],
                  kok['kok_data']['benif_mname'],
                  kok['kok_data']['benif_lname'],
                  kok['kok_data']['benif_birth_date'].try(:to_date).try(:strftime, "%b %d, %Y"),
                  kok['kok_data']['benif_gender'],
                  kok['kok_data']['benif_relationship']
                ], style: [ left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell, date_format_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, date_format_cell, left_aligned_cell, left_aligned_cell]
              end

            end
          end
        end
        @p
    end
  end
end
