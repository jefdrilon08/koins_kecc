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

          if insurance account.blank?
            render json: { errors: ["insurance account not found"] }, status: :unprocessable_entity
          else
            cmd = ::Members::BuildInsuranceAccount.new(insurance_account: insurance_account)

            cmd.execute!

            render json: cmd.data
          end
        end
      end
    end
  end
end
