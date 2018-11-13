module Api
  module V1
    class LoansController < ApiController
      before_action :authenticate_user!

      def apply
        loan_product  = LoanProduct.where(id: params[:loan_product_id]).first
        member        = Member.where(id: params[:member_id]).first

        config  = {
          loan_product: loan_product,
          member: member,
          user: current_user
        }

        errors  = ::Loans::ValidateApply.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          loan  = ::Loans::Apply.new(
                    config: config
                  ).execute!

          render json: { id: loan.id }
        end
      end

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

          render json: { message: "ok", id: loan.id }
        end
      end
    end
  end
end
