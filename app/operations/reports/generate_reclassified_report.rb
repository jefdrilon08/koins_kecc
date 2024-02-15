module Reports
  class GenerateReclassifiedReport
    def initialize(branch:)
      # @start_date = start_date
      # @end_date = end_date
      @branch = branch 
      
      @p          = Axlsx::Package.new
    end

    def execute!
      if @branch.present?
        queryPerBranch!
      else
        query!
      end
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

          sheet.add_row [
            "RECLASSIFIED REPORT"
            ],style: header
          
          sheet.add_row []
          sheet.add_row [ 
            "BRANCH NAME",
            "IDENTIFICATION NUMBER",
            "MEMBERS NAME",
            "INSURANCE STATUS",
            "RECLASSIFIED"
          ], style: header
          @result.each do |o|
            sheet.add_row [
                branch_name = o.fetch("branch_name"),
                identification_number = o.fetch("identification_number"),
                member_name = o.fetch("member_name"),
                insurance_statuus = o.fetch("insurance_statuus"),
                is_reclassified = o.fetch("is_reclassified")
              ], style: [nil]             
            end
          end
        end
      @p
    end

    def query!
       @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT 
            b.name AS branch_name,
            identification_number AS identification_number,
            CONCAT(a.first_name, ' ', a.middle_name, '', a.last_name) AS member_name,
            insurance_status AS insurance_statuus,
            a.data ->> 'is_reclassified' AS is_reclassified
          FROM Members a
          LEFT JOIN branches b ON a.branch_id = b.id
          WHERE a.data ->> 'is_reclassified' = 'YES'
        EOS
    end

    def queryPerBranch!
       @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
          SELECT 
            b.name AS branch_name,
            identification_number AS identification_number,
            CONCAT(a.first_name, ' ', a.middle_name, '', a.last_name) AS member_name,
            insurance_status AS insurance_statuus,
            a.data ->> 'is_reclassified' AS is_reclassified
          FROM Members a
          LEFT JOIN branches b ON a.branch_id = b.id
          WHERE a.data ->> 'is_reclassified' = 'YES'
            and b.id = '#{@branch}'
        EOS
    end

  end
end
