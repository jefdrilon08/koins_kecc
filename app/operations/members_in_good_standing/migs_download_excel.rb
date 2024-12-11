module MembersInGoodStanding
  class MigsDownloadExcel
    def initialize(record:)
      @p = Axlsx::Package.new
      @records = DataStore.find(record)
      @data = {}
    end
    
    def execute!
      @data[:branch] = @records[:meta]["branch_name"]
      @data[:year]   = @records[:meta]["year"]
  
      records = @records.data.with_indifferent_access
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          # Styles
          @header_cells    = wb.styles.add_style(alignment: { horizontal: :left }, b: true)
          @title_cells     = wb.styles.add_style(alignment: { horizontal: :center }, b: true, border: Axlsx::STYLE_THIN_BORDER)
          @row             = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00")
          @data_row        = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
          @bottom_row      = wb.styles.add_style(alignment: { horizontal: :right }, b: true, border: Axlsx::STYLE_THIN_BORDER)

          # Add rows
          sheet.add_row ["MEMBERS IN GOOD STANDING"], style: @header_cells
          sheet.add_row ["#{Settings.company_name}"], style: @header_cells
          sheet.add_row ["#{Settings.company_address}"], style: @header_cells
          sheet.add_row ["TIN Number: #{Settings.company_tin_number}"], style: @header_cells
          sheet.add_row ["#{@data[:branch]} - #{@data[:year]}"], style: @header_cells
          sheet.add_row []
          sheet.add_row ["MEMBERS", "IDENTIFICATION NUMBER", "CENTER", "OFFICER"], style: @title_cells

          # Add data rows
          records[:records].each_with_index do |value, index|
            member_name   = "#{value[:last_name]} #{value[:first_name]}, #{value[:middle_name]}"
            id_num        = value[:identification_number]
            member_center = value[:center]["name"]
            officer       = "#{value[:officer]["first_name"]} #{value[:officer]["last_name"]}"
            sheet.add_row ["#{member_name}", "#{id_num}", "#{member_center}", "#{officer}"], style: @data_row
          end

          # Set column widths after adding rows
          sheet.column_widths 55, 30, 25, 25  # Adjust these values as needed
        end
      end
      @p
    end
  end
end
