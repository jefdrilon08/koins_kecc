module Api
  module V1
    class DashboardController < ApiController
      before_action :authenticate_user!

      def index
        branch  = Branch.find(params[:branch_id])

        data  = {
        }

        if current_user.roles.include?("OAS")
          data[:loan_products]  = #
        end

        render json: data
      end
    end
  end
end
