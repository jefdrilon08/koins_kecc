module Api
  module Members
    class LoansController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!
      before_action :load_loan!, only: [:show]

      def load_loan!
        @loan = ReadOnlyLoan.find_by_id_and_member_id(
          id: params[:id],
          member_id: @current_member.id
        )

        if @loan.blank?
          render json: { message: 'not found' }, status: :not_found
        end
      end

      def index
        cmd = ::Members::GetLoans.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
      end

      def show
        cmd = ::Members::BuildLoan.new(loan: @loan)

        cmd.execute!

        render json: cmd.payload
      end
    end
  end
end
