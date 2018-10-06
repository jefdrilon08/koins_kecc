module Api
  module V1
    class AccountingController < ApiController
      before_action :authenticate_user!

      def fetch_general_ledger
        start_date  = params[:start_date].try(:to_date)
        end_date    = params[:end_date].try(:to_date)

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
            end_date: end_date
          }

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
            end_date: end_date
          }

          trial_balance_data  = ::Accounting::GenerateTrialBalance.new(
                                  config: config
                                ).execute!

          data  = ::Accounting::FormatTrialBalance.new(
                    trial_balance_data: trial_balance_data
                  ).execute!

          render json: { data: data }
        end
      end
    end
  end
end
