module Reports
  class DownloadForMemberIdGeneratorExcel
    def initialize(report_id:)
      @p = Axlsx::Package.new
      @data_store_id = report_id
      @records = DataStore.find(@data_store_id)
      
    end
    def execute!
      @p.workbook do |wb|
        header  = wb.styles.add_style(alignment: {horizontal: :left}, b: true)
        wb.add_worksheet do |sheet|
          sheet.add_row [
            "Name",
            "Id no.",
            "Address",
            "Date of Birth",
            "Civil Status",
            "Expiration Date",
            "Contact Person",
            "Contact No.",
            "Card Layout"

          ], style: header


          @records.data.each do |r|
            sheet.add_row [
              "#{r["first_name"]}" + " " +"#{r["last_name"]}",
              r["member_id_number"],
              r["address"],
              r["birtdate"],
              r["civil_status"],
              "",
              r["contact_person"],
              "'" +  r["contact_person_number"],
              ""


            ], style: [nil]
          end


        end
      end
      @p
    end

  end
end
