module Api
  module Members
    class LoansController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!
      before_action :load_loan!, only: [:show]

      def load_loan!
        @loan = Loan.find_by_id(
          params[:id]
        )

        if @loan.blank?
          render json: { message: 'not found' }, status: :not_found
        elsif @loan.member_id != @current_member.id
          render json: { message: 'unauthorized' }, status: :unauthorized
        end
      end

      # Loan Application
      def create
      end

      def index
        status = params[:status] || "active"

        if not Loan::STATUSES.include?(status)
          render json: { message: 'invalid status' }, status: :unprocessable_entity
        else
          cmd = ::Members::GetLoans.new(
            member: @current_member,
            status: status
          )

          cmd.execute!

          render json: cmd.payload
        end
      end

      def show
        cmd = ::Members::BuildLoan.new(loan: @loan)

        cmd.execute!

        render json: cmd.payload
      end
    end
  end
end
