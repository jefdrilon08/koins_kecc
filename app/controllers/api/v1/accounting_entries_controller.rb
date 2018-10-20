module Api
  module V1
    class AccountingEntriesController < ApiController
      before_action :authenticate_user!

      def approve
        config  = {
          accounting_entry: AccountingEntry.where(id: params[:id]).first,
          user: current_user
        }

        errors  = ::Accounting::AccountingEntries::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: { errors: errors }, status: 400
        else
          ac  = ::Accounting::AccountingEntries::Approve.new(
                  config: config
                ).execute!

          render json: { message: "ok", id: ac.id }
        end
      end

      def fetch
        config  = {
          id: params[:id],
          book: params[:book],
          reference_number: params[:reference_number],
          branch: Branch.where(id: params[:branch_id]).first
        }

        accounting_entry  = ::Accounting::AccountingEntries::Fetch.new(
                              config: config
                            ).execute!

        render json: accounting_entry
      end

      def save
        accounting_entry_data = params[:accounting_entry_data]

        config  = {
          accounting_entry_data: accounting_entry_data,
          user: current_user,
          id: params[:id]
        }

        errors  = ::Accounting::AccountingEntries::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: { errors: errors }, status: 400
        else
          ac  = ::Accounting::AccountingEntries::Save.new(
                  config: config
                ).execute!
          render json: { message: "ok", id: ac.id }
        end
      end
    end
  end
end
