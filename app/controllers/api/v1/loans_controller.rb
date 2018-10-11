module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!

      def reage
        loan        = Loan.where(id: params[:id]).first
        approved_by = current_user.full_name

        config  = {
          loan: loan,
          approved_by: approved_by
        }
      end
    end
  end
end
