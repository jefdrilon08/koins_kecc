module Api
  module Members
    class LoanApplicationsController < ::Api::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        loan_applications = LoanApplication.pending_or_processing.order(
          "date_applied ASC"
        ).where(
          "member_id = ?",
          @current_member.id
        ).map{ |o|
          o.to_h
        }

        render json: { loan_applications: loan_applications }
      end
    end
  end
end
