module Api
  module V1
    class EquityAccountsController < ApiController
      before_action :authenticate_user!

      def update_equity_value
        equity_account = MemberAccount.equities.where(id: params[:id], account_subtype: "CBU").first
        old_value = equity_account&.data&.with_indifferent_access&.[](:equity_value)
        equity_value = params[:equity_value]

        config = {
          equity_account: equity_account,
          equity_value: equity_value,
          user: current_user
        }

        errors = ::EquityAccounts::ValidateUpdateEquityValue.new(config: config).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          equity_account = ::EquityAccounts::UpdateEquityValue.new(config: config).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} modified CBU equity account #{equity_account.id} equity value from #{old_value} to #{equity_value}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              equity_account: equity_account.id,
              old_equity_value: old_value,
              equity_value: equity_value
            }
          )

          render json: { id: equity_account.id }
        end
      end
    end
  end
end
