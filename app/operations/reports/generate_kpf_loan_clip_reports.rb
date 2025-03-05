module Reports
  class GenerateKpfLoanClipReports
    def initialize(branch:, start_date:, end_date:, status:, approval_date_from:, approval_date_to:)
      @branch_id              = branch
      @start_date             = start_date.try(:to_date)
      @start_date_query       = start_date
      @end_date               = end_date.try(:to_date)
      @end_date_query         = end_date
      @approval_date_from     = approval_date_from.try(:to_date)
      @approval_date_to       = approval_date_to.try(:to_date)
      @status                 = status
      
      @clip = []

      if @branch_id.present? && @status.present? && @start_date.present? && @end_date.present? && @approval_date_from.present? && @approval_date_to.present?
        sql_query = <<-SQL
          SELECT
            id,
            branch_id,
            status,
            date_approved,
            record
          FROM
          kpf_loan_clips,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
            AND (record->'clip_data'->>'effective_date')::date >= '#{@start_date_query}'
            AND (record->'clip_data'->>'effective_date')::date <= '#{@end_date_query}'
            AND date_approved >= '#{@approval_date_from}'
            AND date_approved <= '#{@approval_date_to}'
          ORDER BY
            record->'clip_data'->>'effective_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        clip = query.map do |row|
          clip_records_last = KpfLoanClip.find(row['id']).records_last
          clip_status = row['status']
          clip_date_approved = row['date_approved']
          {
            'record' => clip_records_last,
            'status' => clip_status,
            'date_approved' => clip_date_approved
          }
        end
        @query_clip = clip
      elsif @branch_id.present? && @status.present? && @start_date.present? && @end_date.present?
        sql_query = <<-SQL
          SELECT
            id,
            branch_id,
            status,
            date_approved,
            record
          FROM
          kpf_loan_clips,
          jsonb_array_elements(data->'records') AS record
          WHERE
            branch_id = '#{@branch_id.id}'
            AND status = '#{@status}'
            AND (record->'clip_data'->>'effective_date')::date >= '#{@start_date_query}'
            AND (record->'clip_data'->>'effective_date')::date <= '#{@end_date_query}'
          ORDER BY
            record->'clip_data'->>'effective_date'
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        clip = query.map do |row|
          clip_records_last = KpfLoanClip.find(row['id']).records_last
          clip_status = row['status']
          clip_date_approved = row['date_approved']
            {
              'record' => clip_records_last,
              'status' => clip_status,
              'date_approved' => clip_date_approved
            }
        end
        @query_clip = clip
      elsif @branch_id.present? && @status.present? && @approval_date_from.present? && @approval_date_to.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  branch_id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  kpf_loan_clips
              WHERE
                branch_id = '#{@branch_id.id}'
                AND status = '#{@status}'
                AND date_approved >= '#{@approval_date_from}'
                AND date_approved <= '#{@approval_date_to}'
          )
          SELECT
              id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
          ORDER BY
              last_data->'clip_data'->>'effective_date' DESC
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        clip = query.map do |row|
          clip_records_last = KpfLoanClip.find(row['id']).records_last
          clip_status = row['status']
          clip_date_approved = row['date_approved']
            {
              'record' => clip_records_last,
              'status' => clip_status,
              'date_approved' => clip_date_approved
            }
        end
        @query_clip = clip
      elsif @branch_id.present? && @status.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  branch_id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  kpf_loan_clips
              WHERE
                  branch_id = '#{@branch_id.id}'
                  AND status = '#{@status}'
          )
          SELECT
              id,
              branch_id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
          ORDER BY
              last_data->'clip_data'->>'effective_date' DESC
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        clip = query.map do |row|
          clip_records_last = KpfLoanClip.find(row['id']).records_last
          clip_status = row['status']
          clip_date_approved = row['date_approved']
          {
            'record' => clip_records_last,
            'status' => clip_status,
            'date_approved' => clip_date_approved
          }
        end
        @query_clip = clip
      elsif @branch_id.present?
        sql_query = <<-SQL
          WITH last_data_element AS (
              SELECT
                  id,
                  branch_id,
                  status,
                  date_approved,
                  data,
                  jsonb_array_length(data::jsonb -> 'records') - 1 AS last_index,
                  data::jsonb -> 'records' -> (jsonb_array_length(data::jsonb -> 'records') - 1) AS last_data
              FROM
                  kpf_loan_clips
              WHERE
                  branch_id = '#{@branch_id.id}'
          )
          SELECT
              id,
              branch_id,
              status,
              date_approved,
              last_data
          FROM
              last_data_element
          ORDER BY
              last_data->'clip_data'->>'effective_date' DESC
        SQL

        query = ActiveRecord::Base.connection.execute(sql_query)
        clip = query.map do |row|
          clip_records_last = KpfLoanClip.find(row['id']).records_last
          clip_status = row['status']
          clip_date_approved = row['date_approved']
          {
            'record' => clip_records_last,
            'status' => clip_status,
            'date_approved' => clip_date_approved
          }
        end
        @query_clip = clip
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

            sheet.add_row ["KASAGANA-KA CLIP DECLARATION"], style: title_cell

            if @start_date.present? && @end_date.present? && @approval_date_from.present? && @approval_date_to.present?
              sheet.add_row ["Effectivity Date From: #{@start_date} to #{@end_date}"], style: title_cell
              sheet.add_row ["Approval Date From: #{@approval_date_from} to #{@approval_date_to}"], style: title_cell
            elsif @start_date.present? && @end_date.present?
              sheet.add_row ["Effectivity Date From: #{@start_date} to #{@end_date}"], style: title_cell
            elsif @approval_date_from.present? && @approval_date_to.present?
              sheet.add_row ["Approval Date From: #{@approval_date_from} to #{@approval_date_to}"], style: title_cell
            end

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
              "OR DATE",
              "TOTAL COLLECTION "
            ], style: header

            # raise @query_clip.inspect
            @query_clip.each do |clip|
              premium_total += clip['record']['clip_data']['amount'].to_i
              member_count += 1

              sheet.add_row [
                @branch_id.name,
                clip['record']['member']['full_name'],
                clip['record']['member']['identification_number'],
                " ",
                clip['record']['clip_data']['principal'],
                clip['record']['clip_data']['amount'],
                "N/A",
                "N/A",
                clip['record']['clip_data']['amount'],
                "N/A",
                "N/A",
                clip['record']['clip_data']['amount']
              ], style: [left_aligned_cell,left_aligned_cell,left_aligned_cell,left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell, left_aligned_cell]
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
