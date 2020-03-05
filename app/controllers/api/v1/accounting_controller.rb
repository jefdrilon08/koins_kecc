module Api
  module V1
    class AccountingController < ApiController
      before_action :authenticate_user!

      def fetch_general_ledger
        start_date          = params[:start_date].try(:to_date)
        end_date            = params[:end_date].try(:to_date)
        branch_id           = params[:branch_id]
        accounting_code_ids = params[:accounting_code_ids] || []

        if branch_id.present?
          branch              = Branch.where(id: branch_id).first
        end

        config  = {
          start_date: start_date,
          end_date: end_date,
          branch: branch,
          accounting_code_ids: accounting_code_ids
        }

        errors  = ::Accounting::ValidateFetchGeneralLedger.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
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
        start_date      = params[:start_date].try(:to_date)
        end_date        = params[:end_date].try(:to_date)
        branch          = Branch.where(id: params[:branch_id]).first
        accounting_fund = AccountingFund.where(id: params[:accounting_fund_id]).first

        errors  = []

        if start_date.blank?
          errors << "Start date required"
        end

        if end_date.blank?
          errors << "End date required"
        end

        # Check for closing entries
        if start_date.present? and end_date.present? and branch.present?
          latest_closing_record = DataStore.year_end_closings.where(
                                    "status = ? AND meta->>'branch_id' = ?",
                                    "closed",
                                    branch.id
                                  ).order(
                                    "created_at ASC"
                                  ).last

          if latest_closing_record.present?
            date_closed = latest_closing_record.meta["closing_date"].to_date

            if start_date < date_closed and end_date > date_closed
              errors << "Closing date #{date_closed} is in between start and end dates"
            end
          end

          # Check according to accounting entry closing record
          if accounting_fund.present?
            latest_closing_entry = AccountingEntry.year_end_closing.where("date_posted <= ?", end_date).where(accounting_fund_id: accounting_fund.id, branch_id: branch.id).order("date_posted DESC").first
          else
            latest_closing_entry = AccountingEntry.year_end_closing.where("date_posted <= ? AND branch_id = ?", end_date, branch.id).order("date_posted DESC").first
          end

          if latest_closing_entry.present?
            date_closed = latest_closing_entry.date_posted

            if start_date < date_closed and end_date > date_closed
              errors << "Closing date #{date_closed} is in between start and end dates"
            end
          end
        end

        if errors.any?
          render json: { errors: errors }, status: 400
        else
          config  = {
            start_date: start_date,
            end_date: end_date,
            branch: branch || "",
            accounting_fund: accounting_fund || ""
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
