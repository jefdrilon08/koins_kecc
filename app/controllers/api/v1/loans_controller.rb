module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!

      def reage
        loan        = Loan.where(id: params[:id]).first
        approved_by = current_user.full_name

        errors  = ::Loans::ValidateReage.new( 
                    loan: loan,
                    approved_by: approved_by
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Reage.new(
                    loan: loan,
                    approved_by: approved_by
                  ).execute!

          render message: { message: "ok", id: loan.id }
        end
      end
    end
  end
end
