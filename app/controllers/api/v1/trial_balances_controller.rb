module Api
  module V1
    class TrialBalancesController < ApplicationController
      before_action :authenticate_user!
      
      def delete
        trial_balance = DataStore.trial_balances.done.find(params[:id])
        trial_balance.destroy!

        render json: { message: "ok" }
      end

      def create
        start_date          = params[:start_date].try(:to_date)
        end_date            = params[:jef].try(:to_date)
        #end_date            = params[:end_date].try(:to_date)
        branch_id           = params[:branch_id]
        accounting_fund_id  = params[:accounting_fund_id]

        branch          = Branch.where(id: branch_id).first
        accounting_fund = AccountingFund.where(id: accounting_fund_id).first

        validator = ::Accounting::TrialBalances::ValidateCreate.new(
                      start_date: start_date,
                      end_date: end_date,
                      branch: branch,
                      accounting_fund: accounting_fund,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:messages].any?
          render json: validator.errors, status: 400
        else
          data_store_type = "TRIAL_BALANCE"

          record  = DataStore.create!(
                      status: "processing",
                      meta: {
                        branch_id: branch.id,
                        branch_name: branch.name,
                        start_date: start_date,
                        end_date: end_date,
                        data_store_type: data_store_type,
                        accounting_fund_id: accounting_fund.try(:id),
                        accounting_fund_name: accounting_fund.try(:name),
                        user: {
                          id: current_user.id,
                          first_name: current_user.first_name,
                          last_name: current_user.last_name
                        }
                      },
                      data: {
                        status: "processing"
                      }
                    )

          args = {
            id: record.id,
            data_store_type: data_store_type
          }

          ProcessTrialBalance.perform_later(args)

          render json: { message: "ok", id: record.id, status: "processing" }
        end
      end
    end
  end
end
