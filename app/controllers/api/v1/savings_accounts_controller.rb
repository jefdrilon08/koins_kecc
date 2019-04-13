module Api
  module V1
    class SavingsAccountsController < ApiController
      before_action :authenticate_user!

      def sync_maintaining_balance
        savings_account         = MemberAccount.savings.where(id: params[:id]).first
        old_maintaining_balance = savings_account.maintaining_balance
        maintaining_balance     = params[:maintaining_balance]

        config  = {
          savings_account: savings_account,
          maintaining_balance: maintaining_balance,
          user: current_user
        }

        errors  = ::SavingsAccounts::ValidateSyncMaintainingBalance.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 400
        else
          savings_account = ::SavingsAccounts::SyncMaintainingBalance.new(
                              config: config
                            ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} modified savings account #{savings_account.id} maintaining balance from #{old_maintaining_balance} to #{maintaining_balance}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              savings_account: savings_account.id,
              old_maintaining_balance: old_maintaining_balance,
              maintaining_balance: maintaining_balance
            }
          )

          render json: { id: savings_account.id }
        end
      end

      def index
        members = Member.all.order("last_name ASC").where(branch_id: @branches.pluck(:id))

        savings_accounts  = MemberAccount.savings

        data  = []

        savings_accounts.each do |o|
          data << {
            id: o.id,
            member_id: o.member.id,
            member_identification_number: o.member.identification_number,
            member_full_name: o.member.full_name,
            subtype: o.account_subtype,
            balance: o.balance,
            maintaining_balance: o.maintaining_balance
          }
        end

        render json: { savings_accounts: data }
      end
    end
  end
end
