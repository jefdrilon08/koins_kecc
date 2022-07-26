class ExcelReportsController < ApplicationController
  def index
    @subheader_items = [
        {
          text: "EXCEL REPORTS"
        }
      ]
  end

  def excel_report
        branch_id     = params[:branchId]
        report_date   = params[:reportDate] 
        midas_type    = params[:midasType]
        @branch       = Branch.find(branch_id).name
        config        = {branch_id: branch_id, report_date: report_date}
        args          = {branch_id: branch_id, report_date: report_date}
 
        if branch_id.present?
          filename = "#{@branch}_#{report_date}_#{midas_type}_midas.xlsx"
        else
        end
        
        case midas_type
          when 'MIDAS - PODs'
            excel = ExcelReports::GenerateReportPods.new(config: config).execute!
            #excel = ProcessExcelReport.perform_later(args)
          when 'MIDAS - BARis'
            excel = ExcelReports::GenerateReportBaris.new(config: config).execute!
            #excel = ProcessExcelReport.perform_later(args)
          when 'Member Registry'
            excel = ExcelReports::GenerateMemberRegistry.new(config: config).execute!
          else
        end        
        excel.serialize "#{Rails.root}/tmp/#{filename}"

        send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
 
  end

end	
