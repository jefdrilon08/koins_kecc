module Api
  module V1
    class PagesController < ActionController::API
      def insurance_account_status_reports
        branch = params[:branch]
        insurance_status = params[:insurance_status]

        data = Pages::InsuranceAccountStatusReports.new(
                                      branch: branch,
                                      insurance_status: insurance_status 
                                    ).execute!

        # data[:download_url] = daily_report_insurance_account_status_path(
        #                       branch: branch,
        #                       download: true
        #                       )

        render json: data
      end
    end
  end
end

  