module Reports
  class GenerateBillingLapsedMemberReports
    def initialize(branch:, collection_date_from:, collection_date_to:, status:)
      @branch_id              = branch
      @collection_date_from   = collection_date
      @collection_date_to     = collection_date
      @status                 = status
      @billing = []

      if @branch_id.present? && @status.present? && @collection_date_from.present? && @collection_date_to.present?
        sql_query = <<-SQL
          SELECT
            id,
            status,
            date_approved,
            record
          FROM
          billings,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
            AND date_approved >= '#{@collection_date_from}'
            AND date_approved <= '#{@collection_date_to}'
          ORDER BY
            record->'billing_data'->>'effectivity_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        billing = query.map do |row|
          billing_records_last = Billing.find(row['id']).records_last
          billing_status = row['status']
          billing_date_approved = row['date_approved']
          {
            'record' => billing_records_last,
            'status' => billing_status,
            'date_approved' => billing_date_approved
          }
        end
        @query_billing = billing
      elsif @branch_id.present? && @status.present?
        sql_query = <<-SQL
          SELECT
            id,
            status,
            date_approved,
            record
          FROM
          billings,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
          ORDER BY
            record->'billing_data'->>'effectivity_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        billing = query.map do |row|
          billing_records_last = Billing.find(row['id']).records_last
          billing_status = row['status']
          billing_date_approved = row['date_approved']
            {
              'record' => billing_records_last,
              'status' => billing_status,
              'date_approved' => billing_date_approved
            }
        end
        @query_billing = billing
      elsif @branch_id.present? && @status.present? && @collection_date_from.present? && @collection_date_to.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  billings
              WHERE
                branch_id = '#{@branch_id.id}'
                AND status = '#{@status}'
                AND date_approved >= '#{@collection_date_from}'
                AND date_approved <= '#{@collection_date_to}'
          )
          SELECT
              id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
          ORDER BY
              last_data->'billing_data'->>'effectivity_date' DESC
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        billing = query.map do |row|
          billing_records_last = Billing.find(row['id']).records_last
          billing_status = row['status']
          billing_date_approved = row['date_approved']
            {
              'record' => billing_records_last,
              'status' => billing_status,
              'date_approved' => billing_date_approved
            }
        end
        @query_billing = billing
      elsif @branch_id.present? && @status.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  billings
              WHERE
                  branch_id = '#{@branch_id.id}'
                  AND status = '#{@status}'
          )
          SELECT
              id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
          ORDER BY
              last_data->'billing_data'->>'effectivity_date' DESC
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        billing = query.map do |row|
          billing_records_last = Billing.find(row['id']).records_last
          billing_status = row['status']
          billing_date_approved = row['date_approved']
          {
            'record' => billing_records_last,
            'status' => billing_status,
            'date_approved' => billing_date_approved
          }
        end
        @query_billing = billing
      elsif @branch_id.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  billings
              WHERE
                  branch_id = '#{@branch_id.id}'
          )
          SELECT
              id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        billing = query.map do |row|
          billing_records_last = Billing.find(row['id']).records_last
          billing_status = row['status']
          billing_date_approved = row['date_approved']
          {
            'record' => billing_records_last,
            'status' => billing_status,
            'date_approved' => billing_date_approved
          }
        end
        @query_billing = billing
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

            sheet.add_row ["Lapsed Members with payment without reinstatement"], style: title_cell

            if @collection_date_from.present? && @collection_date_to.present?
              sheet.add_row ["Collection Date From: #{@collection_date_from} to #{@collection_date_to}"], style: title_cell
            end

            sheet.add_row []

            sheet.add_row [
              "Branch",
              "Center",
              "MemberName",
              "InsuranceStatus"
            ], style: header

            # raise @query_billing.inspect
            @query_billing.each do |billing|
              premium_total += billing['record']['billing_data']['premium_coverage'].to_i
              member_count += 1

              sheet.add_row [
                billing['date_approved'].try(:to_date).try(:strftime, "%b %d, %Y"),
                billing['status'],
                billing['record']['billing_data']['plan_type'],
                billing['record']['billing_data']['plan_category'],
                billing['record']['billing_data']['partner'],
              
              ], style: [left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell]
            end

          end
        end
        @p
    end
  end
end
