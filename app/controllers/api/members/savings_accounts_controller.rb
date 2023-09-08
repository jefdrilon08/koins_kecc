module Api
  module Members
    class SavingsAccountsController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        cmd = ::Members::GetSavings.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
      end

      def show
        id = params[:id]

        if id.blank?
          render json: { errors: ["id required"] }, status: :unprocessable_entity
        else
          savings_account = MemberAccount.find_by_id_and_member_id_and_account_type(id, @member.id, "SAVINGS")

          if savings_account.blank?
            render json: { errors: ["insurance account not found"] }, status: :unprocessable_entity
          else
            cmd = ::Members::BuildSavingsAccount.new(savings_account: savings_account)

            cmd.execute!

            render json: cmd.data
          end
        end
      end

      def more_payments
        id      = params[:id]
        last_id = params[:last_id]

        if id.blank?
          render json: { errors: ["id required"] }, status: :unprocessable_entity
        elsif last_id.blank?
          render json: { errors: ["last_id required"] }, status: :unprocessable_entity
        else
          savings_account = MemberAccount.find_by_id_and_member_id_and_account_type(id, @member.id, "SAVINGS")

          if savings_account.blank?
            render json: { errors: ["insurance account not found"] }, status: :unprocessable_entity
          else
            last_transaction = AccountTransaction.find(last_id)

            payments  = AccountTransaction.where(
                          subsidiary_id: id
                        ).where.not(
                          id: last_id
                        ).where(
                          "DATE(transacted_at) <= ?",
                          last_transaction.transacted_at.to_date
                        ).order("transacted_at DESC, created_at DESC").limit(20).map{ |o|
                          {
                            id: o.id,
                            amount: o.amount.to_f,
                            transaction_type: o.transaction_type,
                            transacted_at: o.transacted_at.strftime("%b %d, %Y"),
                            is_interest: o.interest? ? "yes" : "no"
                          }
                        }

            last_id = nil

            if payments.last
              last_id = payments.last[:id]
            end

            render json: { payments: payments, last_id: last_id }
          end
        end
      end
    end
  end
end
