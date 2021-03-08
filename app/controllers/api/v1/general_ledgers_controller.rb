module Api
  module V1
    class GeneralLedgersController < ApiController
      before_action :authenticate_app_request!
      before_action :authenticate_core_user!

      def delete
        general_ledger = DataStore.general_ledgers.done.find(params[:id])
        general_ledger.destroy!

        render json: { message: "ok" }
      end

      def fetch
        general_ledger = DataStore.general_ledgers.done.find(params[:id])

        render json: { data: general_ledger.data }
      end

      def create
        start_date          = params[:start_date].try(:to_date)
        end_date            = params[:end_date].try(:to_date)
        branch_id           = params[:branch_id]
        accounting_fund_id  = params[:accounting_fund_id]

        branch          = Branch.find_by_id(branch_id)
        accounting_fund = AccountingFund.find_by_id(accounting_fund_id)

        validator = ::Accounting::GeneralLedgers::ValidateCreate.new(
                      start_date:       start_date,
                      end_date:         end_date,
                      branch:           branch,
                      accounting_fund:  accounting_fund,
                      user:             @core_user
                    )

        validator.execute!

        if validator.errors[:messages].any?
          render json: validator.errors, status: 400
        else
          data_store_type = "GENERAL_LEDGER"

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
                          id: @core_user.id,
                          first_name: @core_user.first_name,
                          last_name: @core_user.last_name
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

          ProcessGeneralLedger.perform_later(args)

          render json: { message: "ok", id: record.id, status: "processing" }
        end
      end
    end
  end
end
