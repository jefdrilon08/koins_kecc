 module DataStores
  class GenerateInsurancePersonalFundReportExcel
    def initialize(config:)
      @config = config
      @record   = @config[:record]
      @p        = Axlsx::Package.new
      @data     = @record.data.with_indifferent_access
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
            "Status",
            "Officer",
            "Center",
            "Retirement Fund",
            "Life Insurance Fund",
            "Hospital Income Plan",
            "Credit Life Insurance Plan",
            "Equity Value"
          ], 
          style: label_cell

          @count = 0
          @rf_total = 0.00
          @lif_total = 0.00
          @hiip_total = 0.00
          @clip_total = 0.00
          @ev_total = 0.00

          @records.each_with_index do |record, i|
            
            row = []
            row << "#{record[:member][:last_name].try(:upcase)}, #{record[:member][:first_name].try(:upcase)}, #{record[:member][:middle_name].try(:upcase)}"
            row << "#{record[:member][:status].try(:upcase)}"
            row << "#{record[:officer][:last_name].try(:upcase)}, #{record[:officer][:first_name].try(:upcase)}, #{record[:officer][:middle_name].try(:upcase)}"
            row << "#{record[:center][:name].try(:upcase)}"
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Retirement Fund" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Life Insurance Fund" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Hospital Income Insurance Plan" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Credit Life Insurance Plan" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Equity Value" }.first[:balance].to_f.round(2)

            @rf_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Retirement Fund" }.first[:balance].to_f.round(2)
            @lif_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Life Insurance Fund" }.first[:balance].to_f.round(2)
            @hiip_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Hospital Income Insurance Plan" }.first[:balance].to_f.round(2)
            @clip_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Credit Life Insurance Plan" }.first[:balance].to_f.round(2)
            @ev_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Equity Value" }.first[:balance].to_f.round(2)

            @count += 1
            sheet.add_row row      
          end
      
          sheet.add_row []
          sheet.add_row [
            "TOTAL",
            @count, 
            "",
            "", 
            @rf_total,
            @lif_total,
            @hiip_total,
            @clip_total
            @ev_total
            ],
          style: [label_cell, count_cell, nil, nil, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold]
           
          sheet.add_row []
        end
      end
      
      @p
    end
  end
end