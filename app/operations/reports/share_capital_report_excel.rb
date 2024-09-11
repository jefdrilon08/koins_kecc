module Reports
  class ShareCapitalReportExcel
    def initialize(share_capital_data:)
      @p = Axlsx::Package.new
      @data = share_capital_data
    end

    def execute!(filepath)
      wb = @p.workbook
      wb.add_worksheet(name: "Report") do |sheet|
        sheet.add_row ["Name", "Sato", "Subscription Date", "Amount Subscribe", "Paid Up", "Balance"]
        
        @data.each do |record|
          sheet.add_row [
            record[:full_name],
            record[:branch_name],
            record[:subscription_date]
          ]
        end
      end
      @p.serialize(filepath)
    end
  end
end