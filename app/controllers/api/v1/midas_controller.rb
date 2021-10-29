module Api
  module V1
    class MidasController < ApplicationController
      
      def generate
        branch_id     = params[:branchId]
        report_date   = params[:reportDate] 
        @branch       = Branch.find(branch_id).name
        config      = {branch_id: branch_id, report_date: report_date}
        if branch_id.present?
          filename = "#{@branch}_#{report_date}_midas.xlsx"
        else
        end

        excel = ::Midas::GenerateReport.new(
                        config: config
        ).execute!
        excel.serialize "#{Rails.root}/tmp/#{filename}"

        send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
 
      end
    
    end
  end
end 
