module Api
  module V1
    class SavingsAccountsController < ApiController
      before_action :authenticate_user!

      def approve_withdrawal_request
        member_account  = MemberAccount.savings.where(id: params[:id]).first
        data_store      = DataStore.where(id: params[:data_store_id]).first

        config  = {
          member_account: member_account,
          data_store: data_store,
          user: current_user
        }

        errors  = ::MemberAccounts::TimeDeposit::ValidateApproveWithdrawalRequest.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::MemberAccounts::TimeDeposit::ApproveWithdrawalRequest.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def delete_withdrawal_request
        member_account  = MemberAccount.savings.where(id: params[:id]).first
        data_store      = DataStore.where(id: params[:data_store_id]).first

        config  = {
          member_account: member_account,
          data_store: data_store,
          user: current_user
        }

        errors  = ::MemberAccounts::TimeDeposit::ValidateDeleteWithdrawalRequest.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          data_store.destroy!

          render json: { message: "ok" }
        end
      end

      def request_time_deposit_withdrawal
        member_account  = MemberAccount.savings.where(id: params[:id]).first
        branch          = member_account.branch
        
        config  = {
          member_account: member_account,
          branch: branch,
          user: current_user
        }

        errors  = ::MemberAccounts::TimeDeposit::ValidateRequestTimeDepositWithdrawal.new(
                    config: config 
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          data  = ::MemberAccounts::TimeDeposit::GenerateWithdrawalRequest.new(
                    config: config
                  ).execute!

          center  = member_account.center
          branch  = member_account.branch
          member  = member_account.member

          meta = {
            data_store_type: "TIME_DEPOSIT_WITHDRAWAL",
            member_account: {
              id: member_account.id,
              balance: member_account.balance,
              maintaining_balance: member_account.maintaining_balance,
              account_type: member_account.account_type,
              account_subtype: member_account.account_subtype,
              center: {
                id: center.id,
                name: center.name
              },
              branch: {
                id: branch.id,
                name: branch.name
              },
              member: {
                id: member.id,
                first_name: member.first_name,
                middle_name: member.middle_name,
                last_name: member.last_name
              }
            }
          }

          data_store  = DataStore.new(
                          meta: meta,
                          data: data,
                          status: "pending"
                        )

          data_store.save!

          render json: { message: "ok" }
        end
      end

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

        if errors[:messages].any?
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
