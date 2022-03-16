module Reports
  class DownloadForMemberIdGeneratorExcel
    def initialize(report_id:)
      @p = Axlsx::Package.new
      @data_store_id = report_id
      @records = DataStore.find(@data_store_id)
      
    end
    def execute!
      @p.workbook do |wb|
        wb.add_worksheet do |sheet|
          @header_cells    = wb.styles.add_style(alignment:{horizontal: :left}, b:true)
          @title_cells = wb.styles.add_style(alignment: {horizontal: :center}, b: true, border: Axlsx::STYLE_THIN_BORDER)
          #@row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00")
          #@data_row = wb.styles.add_style(border: Axlsx::STYLE_THIN_BORDER)
          sheet.add_row ["Names", "Id no.", "Address", "Date of Birth", "Civil Status", "Expiration Date","Contact Person", "Contact No.", "Card Layout"], style: @header_cells
          
          @records.data.each do |record|
            full_name = " #{record["first_name"]} #{record["last_name"]} "
            id_number = record["member_id_number"]
            address = record["address"]
            date_of_birth = record["birtdate"]
            civil_status = record["civil_status"]
            contact_person = record["contact_person"]
            contact_person_number = record["contact_person_number"]

            sheet.add_row ["#{full_name}", "#{id_number}", "#{address}", "#{date_of_birth}", "#{civil_status}","","#{contact_person}","#{contact_person_number}"]
      
          end

        end
      end
      @p
    end
  end
end
