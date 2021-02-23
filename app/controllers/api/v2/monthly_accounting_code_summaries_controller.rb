module Api
  module V2
    class MonthlyAccountingCodeSummariesController < ApiController
      before_action :authenticate_app_request!
      before_action :authenticate_core_user!

      def create
        branch_id = params[:branch_id]
        year      = params[:year].try(:to_i)
        month     = params[:month].try(:to_i)

        cmd = ::MonthlyAccountingCodeSummaries::ValidateCreate.new(
                config: {
                  branch_id: branch_id,
                  year: year,
                  month: month
                }
              )

        cmd.execute!

        if cmd.errors[:full_messages].any?
          render json: cmd.errors, status: 400
        else
          ProcessMonthlyAccountingCodeSummaries.perform_later({
            branch_id: branch_id,
            year: year,
            month: month
          })

          render json: { message: "ok" }
        end
      end
    end
  end
end
