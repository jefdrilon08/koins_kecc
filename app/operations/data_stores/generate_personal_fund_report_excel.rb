module DataStores
  class GeneratePersonalFundReportExcel
    def initialize(config:)
      @config = config
      
      @record   = @config[:record]
      @p        = Axlsx::Package.new

      @data = @record.data.with_indifferent_access

      @records = @data[:records]
    end

    def execute!
      @p.workbook do |wb|
         wb.add_worksheet do |sheet|
          header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
          title_cell = wb.styles.add_style alignment: { horizontal: :center }, b: true, font_name: "Calibri"
          label_cell = wb.styles.add_style b: true, font_name: "Calibri"
          count_cell = wb.styles.add_style  b: true, alignment: { horizontal: :right }, format_code: "0", font_name: "Calibri"
          currency_cell = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri"
          currency_cell_right_bold = wb.styles.add_style num_fmt: 3, alignment: { horizontal: :right }, format_code: "#,##0.00", font_name: "Calibri", b: true
          percent_cell = wb.styles.add_style num_fmt: 9, alignment: { horizontal: :left }, font_name: "Calibri"
          left_aligned_cell = wb.styles.add_style alignment: { horizontal: :left }, font_name: "Calibri"
          underline_cell = wb.styles.add_style u: true, font_name: "Calibri"
          header_cells = wb.styles.add_style b: true, alignment: { horizontal: :center }, font_name: "Calibri"
          date_format_cell = wb.styles.add_style format_code: "mm-dd-yyyy", font_name: "Calibri", alignment: { horizontal: :right }
          default_cell = wb.styles.add_style font_name: "Calibri"

          # For header
          sheet.add_row [ 
            "Member",
            "Officer",
            "Center",
            "K-IMPOK",
            "Golden-K",
            "Savings Investment Fund",
            "Personal Savings Account",
            "Retirement Fund",
            "Life Insurance Fund",
            "Share Capital",
            "CBU"
          ], 
          style: label_cell

          @count = 0
          @kimpok_total = 0
          @goldenk_total = 0
          @sifund_total = 0
          @psa_total = 0
          @rt_total = 0
          @lif_total = 0
          @sc_total = 0
          @cbu_total = 0


          @records.each_with_index do |record, i|
            
            row = []
            row << "#{record[:member][:last_name]}, #{record[:member][:first_name]}, #{record[:member][:middle_name]}"
            row << "#{record[:officer][:last_name]}, #{record[:officer][:first_name]}, #{record[:officer][:middle_name]}"
            row << "#{record[:center][:name]}"
              record[:accounts].each do |a|
                row << a[:balance]
                @kimpok_total = row[:balance] + a[:balance]
              end
              
            #@kimpok_total += record[:accounts][0][:balance].to_d
            @goldenk_total += record[:accounts][1][:balance].to_d
            @sifund_total += record[:accounts][2][:balance].to_d
            @psa_total += record[:accounts][3][:balance].to_d
            @rt_total += record[:accounts][4][:balance].to_d
            @lif_total += record[:accounts][5][:balance].to_d
            @sc_total  += record[:accounts][6][:balance].to_d
            @cbu_total += record[:accounts][7][:balance].to_d
            @count += 1
            sheet.add_row row    
          end
      
          sheet.add_row []
          sheet.add_row [
            "TOTAL",
            @count, 
            "", 
            @kimpok_total, 
            @goldenk_total, 
            @sifund_total,
            @psa_total,
            @rt_total,
            @lif_total,
            @sc_total,
            @cbu_total,
            ""
            ],
          style: [label_cell, count_cell, nil, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold,currency_cell_right_bold]
           
          sheet.add_row []
        end
      end
      
      @p
    end
  end
end