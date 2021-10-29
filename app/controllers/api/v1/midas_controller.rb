module Api
  module V1
    class MidasController < ApplicationController
      
      def generate
        branch_id     = params[:branchId]
        report_date   = params[:reportDate] 
        midas_type    = params[:midasType]
        @branch       = Branch.find(branch_id).name
        config      = {branch_id: branch_id, report_date: report_date}
        if branch_id.present?
          filename = "#{@branch}_#{report_date}_#{midas_type}_midas.xlsx"
        else
        end
        
        if midas_type == 'PODs'
          excel = Midas::GenerateReport.new(
                        config: config
          ).execute!
        else
          
        end

        excel.serialize "#{Rails.root}/tmp/#{filename}"

        send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
 
      end
    
    end
  end
end 
