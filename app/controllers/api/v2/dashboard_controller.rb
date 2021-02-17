module Api
  module V2
    class DashboardController < ApiController
      before_action :authenticate_app_request!
      before_action :authenticate_core_user!

      def generate_daily_report
        branch_id = params[:branch_id]
        as_of     = params[:as_of].try(:to_date)

        cmd = ::Dashboard::ValidateGenerateDailyReport.new(
                config: {
                  branch_id: branch_id,
                  as_of: as_of
                }
              )

        cmd.execute!

        if cmd.errors[:full_messages].any?
          render json: cmd.errors, status: 400
        else
          branch = Branch.find(branch_id)

          ::Dashboard::GenerateDailyReport.new(
            config: {
              branch: branch,
              as_of: as_of
            }
          ).execute!

          render json: { message: "ok" }
        end
      end
    end
  end
end
