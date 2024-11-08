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
          when 'MIDAS - PODs Closing'
            excel = ExcelReports::GenerateReportPodsClosing.new(config: config).execute!
          else
        end        
        excel.serialize "#{Rails.root}/tmp/#{filename}"

        send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
 
  end

  def midas_closing_report
    branch_id  = params[:branch]
    start_date = params[:start_date]
    end_date   = params[:end_date]
    type       = params[:midas_type]

    if branch_id.present?
      @branch = Branch.find(branch_id)
      @filename = "#{@branch.name}_#{type}_midas.xlsx"
    end
    
    config = {
      branch_id: branch_id,
      start_date: start_date,
      end_date: end_date
    }

    case type
      when 'MIDAS - PODs Closing'
        excel = ::ExcelReports::GenerateReportPodsClosing.new(config: config).execute!
      when 'MIDAS - BARis Closing'
        excel = ::ExcelReports::GenerateReportBarisClosing.new(config: config).execute!
      else
    end

   

    excel.serialize "#{Rails.root}/tmp/#{@filename}"
     send_file "#{Rails.root}/tmp/#{@filename}", filename: "#{@filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end

 def loan_report
  branch_id = params[:branch]
  as_of = params[:as_of]
  loan_id = params[:loan]


  if branch_id.present? && as_of.present? && loan_id.present?
    @loan = LoanProduct.find(loan_id).name
    @branch = Branch.find(branch_id)
    @filename = "#{@branch.name}_Loan_Report_#{@loan}.xlsx"

    config = {
      branch_id: branch_id,
      as_of: as_of,
      loan_id: loan_id
    }

    excel = ::ExcelReports::GenerateReportLoan.new(config: config).execute!

    excel.serialize "#{Rails.root}/tmp/#{@filename}"
     send_file "#{Rails.root}/tmp/#{@filename}", filename: "#{@filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end
end

  

end	
