module Api
  module V1
    class DashboardController < ApiController
      before_action :authenticate_user!

      def index
        branch  = Branch.find(params[:branch_id])

        data  = {
        }

        if current_user.roles.include?("OAS")
          branch_loan_stats = DataStore.branch_loans_stats.order("(meta->>'as_of')::date ASC").last
          data[:branch_loan_stats]  = branch_loans_stats
        end

        render json: data
      end
    end
  end
end
