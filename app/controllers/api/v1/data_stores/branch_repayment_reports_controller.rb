module Api
  module V1
    module DataStores
      class BranchRepaymentReportsController < ActionController::Base
        before_action :authenticate_user!

        def fetch
          @record = DataStore.branch_repayment_reports.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            render json: @record
          end
        end

        def queue
          @data_store_type  = "BRANCH_REPAYMENT_REPORT"
          @as_of            = params[:as_of].try(:to_date) || Date.today
          @branch           = Branch.find(params[:branch_id])

          @record = DataStore.branch_repayment_reports.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                      @branch.id,
                      @as_of
                    ).first

          if @record.blank?
            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          branch: {
                            id: @branch.id,
                            name: @branch.name
                          },
                          as_of: @as_of,
                          data_store_type: @data_store_type
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          args  = {
            record: @record,
            data_store_type: @data_store_type
          }

          ProcessBranchRepaymentReport.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
