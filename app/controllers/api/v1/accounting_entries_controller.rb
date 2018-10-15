module Api
  module V1
    class AccountingEntriesController < ApiController
      before_action :authenticate_user!

      def fetch
        config  = {
          book: params[:book],
          reference_number: params[:reference_number],
          branch: Branch.where(id: params[:branch_id]).first
        }

        accounting_entry  = ::Accounting::AccountingEntries::Fetch.new(
                              config: config
                            ).execute!

        render json: accounting_entry
      end
    end
  end
end
