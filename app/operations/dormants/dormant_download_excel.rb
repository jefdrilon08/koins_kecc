module Dormants
  class DormantDownloadExcel
    def initialize(record:)
    @p = Axlsx::Package.new

    @records = DataStore.find(record)
     @data = {}
    end
    
    def execute!
      @data[:branch] = @records[:meta]["branch_name"]
      @data[:year]   = @records[:as_of]

      records = @records.data.with_indifferent_access
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
        @header_cells    = wb.styles.add_style(alignment:{horizontal: :left}, b:true)
        @title_cells = wb.styles.add_style(alignment: {horizontal: :center}, b: true, border: Axlsx::STYLE_THIN_BORDER)
        @row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00")
        @data_row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
        @bottom_row = wb.styles.add_style(alignment: {horizontal: :right}, b: true, border: Axlsx::STYLE_THIN_BORDER)
        sheet.add_row ["DORMANT"] , style: @header_cells
        sheet.add_row ["#{Settings.company_name}"], style: @header_cells
        sheet.add_row ["#{Settings.company_address}"], style: @header_cells
        sheet.add_row ["TIN Number: #{Settings.company_tin_number}"] , style: @header_cells
        sheet.add_row ["#{@data[:branch]} - #{@data[:year]}"], style: @header_cells
        sheet.add_row []
        sheet.add_row ["MEMBERS","CENTER","STATUS","K-IMPOK","DORMANT FEE"], style: @title_cells
        records[:record].each_with_index do |value, index|
          member_name   = value[:full_name]
          member_center = value[:center_name]
          member_status = value[:member_status]
          balance   = value[:balance].to_f.round(2)
          dormant_fee = value[:dormant_fee].to_f.round(2)
          sheet.add_row ["#{member_name}","#{member_center}","#{member_status}","#{balance}","#{dormant_fee}"], style: @data_row
        
        end
        records[:header].each_with_index do |value, index|
          total_balance   = value[:total_amount].to_f.round(2)
          total_dormant_fee   = value[:total_payment].to_f.round(2)
          sheet.add_row ["TOTAL", "", "", "#{total_balance}", "#{total_dormant_fee}"], style: @bottom_row
        end
      end
    end
    @p
  end
end
end
