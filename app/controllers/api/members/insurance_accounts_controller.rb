module Api
  module Members
    class InsuranceAccountsController < ::Api::FrontController
      before_action :authenticate_member!

      def index
        accounts  = @member.member_accounts.insurance

        total_balance = accounts.sum(:balance).to_f

        accounts  = accounts.map{ |o|
                      {
                        id: o.id,
                        balance: o.balance.to_f,
                        type: o.account_subtype
                      }
                    }

        render json: { total_balance: total_balance, accounts: accounts }
      end

      def show
        id = params[:id]

        if id.blank?
          render json: { errors: ["id required"] }, status: :unprocessable_entity
        else
          insurance_account = MemberAccount.find_by_id_and_member_id_and_account_type(id, @member.id, "INSURANCE")

          if insurance_account.blank?
            render json: { errors: ["insurance account not found"] }, status: :unprocessable_entity
          else
            cmd = ::Members::BuildInsuranceAccount.new(insurance_account: insurance_account)

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
          insurance_account = MemberAccount.find_by_id_and_member_id_and_account_type(id, @member.id, "INSURANCE")

          if insurance_account.blank?
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
                            transacted_at: o.transacted_at.strftime("%b %d, %Y")
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
