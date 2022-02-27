module Api
  module Members
    class LoansController < ::Api::FrontController
      before_action :authenticate_member!

      def show
        id = params[:id]

        if id.blank?
          render json: { errors: ["id required"] }, status: :unprocessable_entity
        else
          loan = Loan.find_by_id_and_member_id(id, @member.id)

          if loan.blank?
            render json: { errors: ["loan not found"] }, status: :unprocessable_entity
          else
            cmd = ::Members::BuildLoan.new(loan: loan)

            cmd.execute!

            render json: cmd.data
          end
        end
      end
    end
  end
end
