module Reports
  class GenerateCollectionsBlipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date       = start_date
      @end_date         = end_date
      @branch           = branch
      @all_branches     = Branch.all
      @branch_ids       = Branch.pluck(:id).map { |id| "'#{id}'" }.join(", ")
      # raise @branch_ids.inspect

      if @branch.present? && @start_date.present? && @end_date.present?
        # OLD QUERY
        # @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("identification_number ASC")
        # @members  = Member.where("data->>'recognition_date' <= ? AND branch_id = ?", @end_date, @branch).order("identification_number ASC")

        # NEW QUERY
        query = <<-SQL
          Select
            d.name AS branch_name,
            a.branch_id,
            a.identification_number as certificate_number,
            concat(a.first_name, ',  ', a.middle_name , ',  ' , a.last_name) as name_of_member,
            a.status AS member_status,
            a.insurance_status as insurance_status,
            a.data->>'recognition_date' AS recognition_date,
            MAX(c.transacted_at) as or_date,
            'N/A' as premium_tax,
            b.account_subtype as account_subtype,
            b.id AS member_account_id,
            c.transaction_type as transaction_type,
            SUM(c.amount) AS sum_amount
          from members a
            left join member_accounts b On a.id = b.member_id
            inner join account_transactions c ON b.id = c.subsidiary_id
            left join branches d ON a.branch_id = d.id
          where
            a.insurance_status NOT IN ('pending')
            AND d.id = '#{@branch}'
            AND a.data->>'recognition_date' <= '#{@end_date}'
            AND b.account_type = 'INSURANCE'
            AND b.account_subtype IN ('Life Insurance Fund', 'Retirement Fund')
            AND c.data->>'is_interest' = 'false'
            AND c.transaction_type IN ('deposit')
            AND c.transacted_at between '#{@start_date}' and '#{@end_date}'
          group by
            d.name,
            a.branch_id,
            a.identification_number,
            a.first_name,
            a.middle_name,
            a.last_name,
            a.status,
            a.insurance_status,
            a.data->>'recognition_date',
            b.account_subtype,
            b.id,
            c.transaction_type
          Order by
          a.identification_number ASC,
          b.account_subtype ASC
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      elsif @start_date.present? && @end_date.present?
        # OLD QUERY
        # @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", @start_date, @end_date).order("identification_number ASC")

        # NEW QUERY
        query = <<-SQL
          Select
            d.name AS branch_name,
            a.branch_id,
            a.identification_number as certificate_number,
            concat(a.first_name, ',  ', a.middle_name , ',  ' , a.last_name) as name_of_member,
            a.status AS member_status,
            a.insurance_status as insurance_status,
            a.data->>'recognition_date' AS recognition_date,
            MAX(c.transacted_at) as or_date,
            'N/A' as premium_tax,
            b.account_subtype as account_subtype,
            b.id AS member_account_id,
            c.transaction_type as transaction_type,
            SUM(c.amount) AS sum_amount
          from members a
            left join member_accounts b On a.id = b.member_id
            inner join account_transactions c ON b.id = c.subsidiary_id
            left join branches d ON a.branch_id = d.id
          where
            a.insurance_status NOT IN ('pending')
            AND a.data->>'recognition_date' <= '#{@end_date}'
            AND b.account_type = 'INSURANCE'
            AND b.account_subtype IN ('Life Insurance Fund', 'Retirement Fund')
            AND c.data->>'is_interest' = 'false'
            AND c.transaction_type IN ('deposit')
            AND c.transacted_at between '#{@start_date}' and '#{@end_date}'
          group by
            d.name,
            a.branch_id,
            a.identification_number,
            a.first_name,
            a.middle_name,
            a.last_name,
            a.status,
            a.insurance_status,
            a.data->>'recognition_date',
            b.account_subtype,
            b.id,
            c.transaction_type
          Order by
          a.identification_number ASC,
          b.account_subtype ASC
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      end

      @p        = Axlsx::Package.new
    end

    # def query!
    #   @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
    #     SELECT
    #       members.id AS member_uuid,
    #       members.identification_number,
    #       members.first_name,
    #       members.middle_name,
    #       members.last_name,
    #       members.status,
    #       members.insurance_status,
    #       members.data->'recognition_date' AS recognition_date,
    #       tt.member_account_subtype AS account_subtype,
    #       tt.member_account_id AS member_account_id,
    #       COALESCE(SUM(tt.amount::float), 0.00) AS sum_amount
    #     FROM members
    #     LEFT JOIN
    #       (
    #       SELECT
    #         member_accounts.member_id,
    #         member_accounts.id AS member_account_id,
    #         member_accounts.account_subtype AS member_account_subtype,
    #         account_transactions.id AS account_transaction_id,
    #         account_transactions.transacted_at AS latest_transaction_date,
    #         account_transactions.data->>'ending_balance' AS ending_balance,
    #         account_transactions.amount AS amount
    #     FROM
    #         member_accounts
    #     INNER JOIN
    #         account_transactions ON member_accounts.id = account_transactions.subsidiary_id
    #         AND member_accounts.account_type = 'INSURANCE'
    #         AND member_accounts.account_subtype IN ('Life Insurance Fund', 'Retirement Fund')
    #         AND account_transactions.data->>'is_interest' = 'false'
    #         AND account_transactions.transaction_type = 'deposit'
    #         AND account_transactions.transacted_at BETWEEN '#{@start_date}' AND '#{@end_date}'
    #     ORDER BY
    #         member_accounts.id, account_transactions.transacted_at DESC
    #       ) tt ON tt.member_id = members.id
    #     WHERE
    #       members.insurance_status IN ('inforce', 'lapsed', 'dormant', 'resigned', 'inactive')
    #       AND members.branch_id::text = '#{@branch}'
    #       AND members.data->>'recognition_date' <= '#{@end_date}'
    #     GROUP BY
    #       members.id,
    #       tt.member_account_id,
    #       tt.member_account_subtype
    #   EOS
    # end

    def execute!
      # query!

      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header                          = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell                      = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          title_cell_left                 = wb.styles.add_style num_fmt: 12, alignment: { horizontal: :left }, b: true, font_name: "Calibri"
          label_cell                      = wb.styles.add_style b: true, font_name: "Calibri"
          currency_cell                   = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right             = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold        = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell                    = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell               = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell                  = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells                    = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell                = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell                    = wb.styles.add_style font_name: "Calibri"


          sheet.add_row ["BLIP COLLECTIONS"], style: title_cell_left
          if @start_date.present? && @end_date.present? && @approval_date_from.present? && @approval_date_to.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @start_date.present? && @end_date.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @start_date.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @end_date.present?
            sheet.add_row ["Date Range: #{@end_date}"], style: label_cell
          end

          sheet.add_row []

          sheet.add_row [
            "Branch Name",
            "Certificate Number",
            "Member Name",
            "Status",
            "Insurance Status",
            "Recognition Date",
            "OR Date",
            "Premium Tax",
            "Account Subtype",
            "Member Account ID",
            "SUM Amount"
          ], style: header

          @members.each do |m|
            sheet.add_row [
              m["branch_name"],
              m["certificate_number"],
              m["name_of_member"],
              m["member_status"],
              m["insurance_status"],
              m["recognition_date"],
              m["or_date"],
              m["premium_tax"],
              m["account_subtype"],
              m["member_account_id"],
              m["sum_amount"]
            ]
          end
        end
      end
      @p
    end
  end
end
