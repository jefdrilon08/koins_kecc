module Accounting
  module AccountingCodes
    class DownloadExcelChartOfAccounts
      def initialize
        @chart = []
        @p = Axlsx::Package.new
        @accounting = AccountingCode.where(id: AccountingCode.all.ids).order(:category,:code).pluck(:code,:name,:category)
      end
      
      def execute!
        @p.workbook do |wb|
          wb.add_worksheet do |sheet|
            sheet.add_row ["CODE", "NAME", "CATEGORY"]
              @accounting.each do |acc_code|
                tmp = {}
                tmp[:code]= acc_code[0]
                tmp[:name]= acc_code[1]
                tmp[:cat]= acc_code[2]
                @chart << tmp
             end
  
              @chart.each do |charts|
                sheet.add_row [
                  charts[:code],
                  charts[:name],
                  charts[:cat]
                  ]
              end
          end
        end
      @p
  end
end
end
end
