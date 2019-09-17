module Api
  module V1
    class AccountingController < ApiController
      before_action :authenticate_user!

      def fetch_general_ledger
        start_date          = params[:start_date].try(:to_date)
        end_date            = params[:end_date].try(:to_date)
        branch_id           = params[:branch_id]
        accounting_code_ids = params[:accounting_code_ids] || []
        branch              = Branch.where(id: branch_id).first

        config  = {
          start_date: start_date,
          end_date: end_date,
          branch: branch,
          accounting_code_ids: accounting_code_ids
        }

        errors  = ::Accounting::ValidateFetchGeneralLedger.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          general_ledger_data  = ::Accounting::GenerateGeneralLedger.new(
                                  config: config
                                ).execute!

          data  = ::Accounting::FormatGeneralLedger.new(
                    general_ledger_data: general_ledger_data
                  ).execute!

          render json: { data: data }
        end
      end

      def fetch_trial_balance
        start_date  = params[:start_date].try(:to_date)
        end_date    = params[:end_date].try(:to_date)
        branch      = Branch.where(id: params[:branch_id]).first

        accounting_fund = AccountingFund.where(id: params[:accounting_fund_id]).first

        errors  = []

        if start_date.blank?
          errors << "Start date required"
        end

        if end_date.blank?
          errors << "End date required"
        end

        if errors.size > 0
          render json: { errors: errors }, status: 400
        else
          config  = {
            start_date: start_date,
            end_date: end_date,
            branch: branch,
            accounting_fund: accounting_fund
          }

#          trial_balance_data  = ::Accounting::GenerateTrialBalance.new(
#                                  config: config
#                                ).execute!
#
#          data  = ::Accounting::FormatTrialBalance.new(
#                    trial_balance_data: trial_balance_data
#                  ).execute!
          data  = ::Accounting::FetchTrialBalance.new(
                    config: config
                  ).execute!

          render json: { data: data }
        end
      end
    end
  end
end
