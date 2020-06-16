 module DataStores
  class GeneratePersonalFundReportExcel
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
            "K-IMPOK",
            "Golden-K",
            "Savings Investment Fund",
            "Personal Savings Account",
            "Time Deposit",
            "Retirement Fund",
            "Life Insurance Fund",
            "Share Capital",
            "CBU",
            "Hospital Income Plan",
            "Credit Life Insurance Plan"
          ], 
          style: label_cell

          @count = 0
          @kimpok_total = 0.00
          @goldenk_total = 0.00
          @sifund_total = 0.00
          @psa_total = 0.00
          @timed_total = 0.00
          @rf_total = 0.00
          @lif_total = 0.00
          @sc_total = 0.00
          @cbu_total = 0.00
          @hiip_total = 0.00
          @clip_total = 0.00

          @records.each_with_index do |record, i|
            
            row = []
            row << "#{record[:member][:last_name].try(:upcase)}, #{record[:member][:first_name].try(:upcase)}, #{record[:member][:middle_name].try(:upcase)}"
            row << "#{record[:member][:status].try(:upcase)}"
            row << "#{record[:officer][:last_name].try(:upcase)}, #{record[:officer][:first_name].try(:upcase)}, #{record[:officer][:middle_name].try(:upcase)}"
            row << "#{record[:center][:name].try(:upcase)}"
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "K-IMPOK" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Golden K" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Savings Investment Fund" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Personal Savings Account" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Time Deposit" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Retirement Fund" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Life Insurance Fund" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Share Capital" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "CBU" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Hospital Income Insurance Plan" }.first[:balance].to_f.round(2)
            row << record[:accounts].select{ |acc| acc[:account_subtype] == "Credit Life Insurance Plan" }.first[:balance].to_f.round(2)

            @kimpok_total += record["accounts"].select{ |acc| acc["account_subtype"] == "K-IMPOK" }.first["balance"].to_f.round(2)
            @goldenk_total += record["accounts"].select{ |acc| acc["account_subtype"] == "Golden K" }.first["balance"].to_f.round(2)
            @sifund_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Savings Investment Fund" }.first[:balance].to_f.round(2)
            @psa_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Personal Savings Account" }.first[:balance].to_f.round(2)
            @timed_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Time Deposit" }.first[:balance].to_f.round(2)
            @rf_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Retirement Fund" }.first[:balance].to_f.round(2)
            @lif_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Life Insurance Fund" }.first[:balance].to_f.round(2)
            @sc_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Share Capital" }.first[:balance].to_f.round(2)
            @cbu_total += record[:accounts].select{ |acc| acc[:account_subtype] == "CBU" }.first[:balance].to_f.round(2)
            @hiip_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Hospital Income Insurance Plan" }.first[:balance].to_f.round(2)
            @clip_total += record[:accounts].select{ |acc| acc[:account_subtype] == "Credit Life Insurance Plan" }.first[:balance].to_f.round(2)

              # record[:accounts].each do |a|
              #   row << a[:balance]
              #   if a[:account_subtype] == "Retirement Fund"
              #     @rt_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Life Insurance Fund"
              #     @lif_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Share Capital"
              #     @sc_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "CBU"
              #     @cbu_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "K-IMPOK"
              #     @kimpok_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Personal Savings Account"
              #     @psa_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Golden K"
              #     @goldenk_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Savings Investment Fund"
              #     @sifund_total += a[:balance].to_d
              #   elsif a[:account_subtype] == "Time Deposit"
              #     @timed_total += a[:balance].to_d
              #   end
              # end
            
            # @goldenk_total += record[:accounts][1][:balance].to_d
            # @sifund_total += record[:accounts][2][:balance].to_d
            # @psa_total += record[:accounts][3][:balance].to_d
            # @timed_total += record[:accounts][4][:balance].to_d
            # @rt_total += record[:accounts][5][:balance].to_d
            # @lif_total += record[:accounts][6][:balance].to_d
            # @sc_total  += record[:accounts][7][:balance].to_d
            # @cbu_total += record[:accounts][8][:balance].to_d
            @count += 1
            sheet.add_row row      
          end
      
          sheet.add_row []
          sheet.add_row [
            "TOTAL",
            @count, 
            "",
            "", 
            @kimpok_total,
            @goldenk_total, 
            @sifund_total,
            @psa_total,
            @timed_total,
            @rf_total,
            @lif_total,
            @sc_total,
            @cbu_total,
            @hiip_total,
            @clip_total
            ],
          style: [label_cell, count_cell, nil, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold, currency_cell_right_bold,currency_cell_right_bold,currency_cell_right_bold,currency_cell_right_bold,currency_cell_right_bold]
           
          sheet.add_row []
        end
      end
      
      @p
    end
  end
end