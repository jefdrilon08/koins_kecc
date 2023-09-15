module Api
  module Members
    class EquityAccountsController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!
      before_action :load_account!, only: [:show, :transactions]

      def load_account!
        @equity_account = MemberAccount.find_by_id_and_account_type(
          params[:id],
          "EQUITY"
        )

        if @equity_account.blank?
          render json: { message: 'not found' }, status: :not_found
        elsif @equity_account.member_id != @current_member.id
          render json: { message: 'unauthorized' }, status: :unauthorized
        end
      end

      def index
        cmd = ::Members::GetEquityAccounts.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
      end

      def show
        cmd = ::Members::BuildEquityAccount.new(
          equity_account: @equity_account
        )

        cmd.execute!
        
        render json: cmd.data
      end

      def transactions
        last_id = params[:last_id]

        cmd = ::MemberAccounts::BuildTransactions.new(
          member: @current_member,
          member_account: @equity_account,
          last_id: last_id
        )

        cmd.execute!

        render json: cmd.data
      end
    end
  end
end
