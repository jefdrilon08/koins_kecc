module Api
  module Members
    class SavingsAccountsController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!
      before_action :load_account!, only: [:show, :transactions]

      def load_account!
        @savings_account = MemberAccount.find_by_id_and_account_type(
          params[:id],
          "SAVINGS"
        )

        if @savings_account.blank?
          render json: { message: 'not found' }, status: :not_found
        elsif @savings_account.member_id != @current_member.id
          render json: { message: 'unauthorized' }, status: :unauthorized
        end
      end

      def index
        cmd = ::Members::GetSavings.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
      end

      def show
        cmd = ::MemberAccounts::BuildSavingsAccount.new(
          savings_account: @savings_account
        )

        cmd.execute!

        render json: cmd.data
      end

      def transactions
        last_id = params[:last_id]

        cmd = ::MemberAccounts::BuildTransactions.new(
          member: @current_member,
          member_account: @savings_account,
          last_id: last_id
        )

        cmd.execute!

        render json: cmd.data
      end
    end
  end
end
