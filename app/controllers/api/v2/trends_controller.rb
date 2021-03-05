module Api
  module V2
    class TrendsController < ApiController
      before_action :authenticate_app_request!
      before_action :authenticate_core_user!

      def fetch_yearly_data
        year            = params[:year].try(:to_i)
        branches        = ReadOnlyBranch.where(id: params[:branch_ids])
        accounting_code = ReadOnlyAccountingCode.find(params[:accounting_code_id])

        cmd = ::Trends::FetchYearlyData.new(
                year:             year,
                branches:         branches,
                accounting_code:  accounting_code
              )

        cmd.execute!

        data = cmd.data

        render json: { data: data }
      end
    end
  end
end
