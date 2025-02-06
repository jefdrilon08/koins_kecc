module Reports
  class GenerateHiipReportExcel
    def initialize(start_date:, end_date:, branch:)
      @start_date   = start_date
      @end_date     = end_date
      @branch       = branch


      if @branch.present? && @start_date.present? && @end_date.present?
        # hiip_accounts = MemberAccount.where("account_subtype = ? AND branch_id = ?", "Hospital Income Insurance Plan", @branch_id)

        # NEW QUERY
                # OLD QUERY
        # @hiip   = Claim.where("date_prepared >= ? AND date_requested <= ? AND branch_id = ? AND claim_type = ?", @start_date, @end_date, @branch, "HIIP").order("created_at DESC")

        # NEW QUERY
        query = <<-SQL
          Select
            branch_name,
            b.identification_number AS identification_number,
            name_of_member,
            pn_number,
            date_released_collection_date,
            date_approved,
            maturity_date,
            status_loan_savings_insurance_trasfer,
            Amount,
            MemberID
          FROM(
            SELECT
              d.name AS branch_name,
              c.identification_number AS identification_number,
              CONCAT(c.last_name,', ',c.first_name,', ', c.middle_name) AS name_of_member,
              a.pn_number AS pn_number,
              a.date_released AS date_released_collection_date,
              a.date_approved AS date_approved,
              a.date_released + interval '1 year' AS maturity_date,
              a.status AS status_loan_savings_insurance_trasfer,
              a.principal AS Amount,
              (c.id)::TEXT as MemberID
            FROM loans a
              LEFT JOIN loan_products b ON a.loan_product_id = b.id
              LEFT JOIN members c ON a.member_id = c.id
              LEFT JOIN branches d ON a.branch_id = d.id
            WHERE
              a.loan_product_id = '806593d3-4ac4-4f58-bc83-76230aca4039'
              AND (a.date_released BETWEEN '#{@start_date}' AND '#{@end_date}')
              AND d.id = '#{@branch}'
          UNION
            SELECT
              b.name AS Branch_Name,
              '' AS identification_number,
              CONCAT(x.acc -> 'member'->>'last_name',' ,', x.acc -> 'member'->>'first_name' ,' ,', x.acc -> 'member'->>'middle_name' ) AS name_of_member,
              ''AS pn_number,
              a.collection_date AS date_released_collection_date,
              a.date_approved AS date_approved,
              a.collection_date + interval '1 year' AS maturity_date,
              a.status AS status_loan_savings_insurance_trasfer,
              (x.acc ->> 'amount')::DECIMAL AS Amount,
              (x.acc -> 'member'->>'id')::TEXT AS MemberID
            FROM savings_insurance_transfer_collections a
              LEFT JOIN branches b ON a.branch_id = b.id
              LEFT JOIN centers c ON a.center_id = c.id
              CROSS JOIN LATERAL jsonb_array_elements(a.data::jsonb->'records') as x(acc)
            WHERE
              a.data->>'status' = 'approved'
              AND a.data->>'insurance_subtype' = 'Hospital Income Insurance Plan'
              AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}')
              AND b.id ='#{@branch}'
          ) Y
            LEFT JOIN members b ON Y.MemberID = (b.id)::TEXT
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      elsif @start_date.present? && @end_date.present?
        # OLD QUERY
        # hiip_accounts = MemberAccount.where("account_subtype = ?", "Hospital Income Insurance Plan")

        # NEW QUERY
        query = <<-SQL
          Select
            branch_name,
            b.identification_number AS identification_number,
            name_of_member,
            pn_number,
            date_released_collection_date,
            date_approved,
            maturity_date,
            status_loan_savings_insurance_trasfer,
            Amount,
            MemberID
          FROM(
            SELECT
              d.name AS branch_name,
              c.identification_number AS identification_number,
              CONCAT(c.last_name,', ',c.first_name,', ', c.middle_name) AS name_of_member,
              a.pn_number AS pn_number,
              a.date_released AS date_released_collection_date,
              a.date_approved AS date_approved,
              a.date_released + interval '1 year' AS maturity_date,
              a.status AS status_loan_savings_insurance_trasfer,
              a.principal AS Amount,
              (c.id)::TEXT as MemberID
            FROM loans a
              LEFT JOIN loan_products b ON a.loan_product_id = b.id
              LEFT JOIN members c ON a.member_id = c.id
              LEFT JOIN branches d ON a.branch_id = d.id
            WHERE
              a.loan_product_id = '806593d3-4ac4-4f58-bc83-76230aca4039'
              AND (a.date_released BETWEEN '#{@start_date}' AND '#{@end_date}')
          UNION
            SELECT
              b.name AS Branch_Name,
              '' AS identification_number,
              CONCAT(x.acc -> 'member'->>'last_name',' ,', x.acc -> 'member'->>'first_name' ,' ,', x.acc -> 'member'->>'middle_name' ) AS name_of_member,
              ''AS pn_number,
              a.collection_date AS date_released_collection_date,
              a.date_approved AS date_approved,
              a.collection_date + interval '1 year' AS maturity_date,
              a.status AS status_loan_savings_insurance_trasfer,
              (x.acc ->> 'amount')::DECIMAL AS Amount,
              (x.acc -> 'member'->>'id')::TEXT AS MemberID
            FROM savings_insurance_transfer_collections a
              LEFT JOIN branches b ON a.branch_id = b.id
              LEFT JOIN centers c ON a.center_id = c.id
              CROSS JOIN LATERAL jsonb_array_elements(a.data::jsonb->'records') as x(acc)
            WHERE
              a.data->>'status' = 'approved'
              AND a.data->>'insurance_subtype' = 'Hospital Income Insurance Plan'
              AND (a.date_approved BETWEEN '#{@start_date}' AND '#{@end_date}')
          ) Y
            LEFT JOIN members b ON Y.MemberID = (b.id)::TEXT
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      end

      @p = Axlsx::Package.new
    end

    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          label_cell = wb.styles.add_style b: true, font_name: "Calibri"
          currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :left }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row ["HIIP COLLECTIONS"], style: label_cell
          if @start_date.present? && @end_date.present? && @approval_date_from.present? && @approval_date_to.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @start_date.present? && @end_date.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @start_date.present?
            sheet.add_row ["Date Range: #{@start_date} to #{@end_date}"], style: label_cell
          elsif @end_date.present?
            sheet.add_row ["Date Range: #{@end_date}"], style: label_cell
          end

          sheet.add_row [
            "Branch Name",
            "Certificate Number",
            "Name of Member",
            "PN Number",
            "Date Released Collection Date",
            "Date Approved",
            "Maturity Date",
            "Status Loan Savings Insurance Transfer",
            "Amount",
            "Member ID"
          ], style: header

          @members.each do |m|
            sheet.add_row [
              m["branch_name"],
              m["identification_number"],
              m["name_of_member"],
              m["pn_number"],
              m["date_released_collection_date"],
              m["date_approved"],
              m["maturity_date"],
              m["status_loan_savings_insurance_trasfer"],
              m["Amount"],
              m["MemberID"]
            ]
          end
        end
      end
      @p
    end
  end
end
