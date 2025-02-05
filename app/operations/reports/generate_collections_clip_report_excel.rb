module Reports
  class GenerateCollectionsClipReportExcel
    def initialize(branch:, start_date:, end_date:)
      @start_date       = start_date
      @end_date         = end_date
      @branch           = branch
      @all_branches     = Branch.all
      @branch_ids       = Branch.pluck(:id).map { |id| "'#{id}'" }.join(", ")
      # raise @branch_ids.inspect

      # this will generate for a specific branch
      if @branch.present? && @start_date.present? && @end_date.present?
        # OLD QUERY
        # @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ? AND branch_id = ?", @start_date, @end_date, @branch).order("identification_number ASC")
        # @members  = Member.where("data->>'recognition_date' <= ? AND branch_id = ?", @end_date, @branch).order("identification_number ASC")

        # NEW QUERY
        query = <<-SQL
          SELECT
            b.name AS branch_name,
            c.identification_number AS identification_Number,
            CONCAT(c.last_name,', ',c.first_name,', ', c.middle_name) AS name_of_member,
            a.data ->>'clip_number' AS clip_number,
            a.pn_number AS pn_number,
            a.date_released AS date_released,
            a.maturity_date AS maturity_date,
            a.num_installments as loan_term,
            case when a.num_installments = 15
                  then ROUND(((a.principal * 0.014) * a.num_installments / 60),2)
                when a.num_installments = 35
                  then ROUND(((a.principal * 0.014) * a.num_installments / 46.666666667),2)
                else
                  ROUND(((a.principal * 0.014) * a.num_installments / 50),2)  end as premium,
            a.principal as amount,
            b.name as loan_product,
            case when a.maturity_date <= '#{@end_date}'
              then 'Matured'
              else a.status
            END as loan_status,
            c.gender as gender,
            c.date_of_birth as date_of_birth
          FROM loans a
            LEFT JOIN loan_products b ON a.loan_product_id = b.id
            LEFT join members c ON a.member_id = c.id
            LEFT join branches d ON a.branch_id = d.id
          where a.date_released between '#{@start_date}' and '#{@end_date}'
          and a.data ->>'clip_number' NOT IN ('','0')
          and d.id = '#{@branch}'
          order by d.name asc, c.identification_number asc
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      # this will generate all branches
      elsif @start_date.present? && @end_date.present?
        # OLD QUERY
        # @members  = Member.where("data ->>'recognition_date' >= ? AND data->>'recognition_date' <= ?", @start_date, @end_date).order("identification_number ASC")

        # NEW QUERY
        query = <<-SQL
          SELECT
            b.name AS branch_name,
            c.identification_number AS identification_Number,
            CONCAT(c.last_name,', ',c.first_name,', ', c.middle_name) AS name_of_member,
            a.data ->>'clip_number' AS clip_number,
            a.pn_number AS pn_number,
            a.date_released AS date_released,
            a.maturity_date AS maturity_date,
            a.num_installments as loan_term,
            case when a.num_installments = 15
                  then ROUND(((a.principal * 0.014) * a.num_installments / 60),2)
                when a.num_installments = 35
                  then ROUND(((a.principal * 0.014) * a.num_installments / 46.666666667),2)
                else
                  ROUND(((a.principal * 0.014) * a.num_installments / 50),2)  end as premium,
            a.principal as amount,
            b.name as loan_product,
            case when a.maturity_date <= '#{@end_date}'
              then 'Matured'
              else a.status
            END as loan_status,
            c.gender as gender,
            c.date_of_birth as date_of_birth
          FROM loans a
            LEFT JOIN loan_products b ON a.loan_product_id = b.id
            LEFT join members c ON a.member_id = c.id
            LEFT join branches d ON a.branch_id = d.id
          where a.date_released between '#{@start_date}' and '#{@end_date}'
          and a.data ->>'clip_number' NOT IN ('','0')
          order by d.name asc, c.identification_number asc
        SQL

        members = ActiveRecord::Base.connection.execute(query)
        @members = members
      end
      @p        = Axlsx::Package.new
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
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          sheet.add_row ["CLIP COLLECTIONS"], style: label_cell
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
            "Member No.",
            "Name of Member",
            "Gender",
            "Date of Birth",
            "CLIP Number",
            "PN Number",
            "Date Released",
            "Maturity Date",
            "Loan Term",
            "Premium",
            "Amount",
            "Loan Product",
            "Loan Status",
          ]


          @members.each do |m|
            sheet.add_row [
              m["branch_name"],
              m["identification_number"],
              m["name_of_member"],
              m["gender"],
              m["date_of_birth"],
              m["clip_number"],
              m["pn_number"],
              m["date_released"],
              m["maturity_date"],
              m["loan_term"],
              m["premium"],
              m["amount"],
              m["loan_product"],
              m["loan_status"]
            ]
          end
        end
      end
      @p
    end
  end
end
