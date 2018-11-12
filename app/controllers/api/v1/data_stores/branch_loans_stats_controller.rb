module Api
  module V1
    module DataStores
      class BranchLoansStatsController < ApplicationController
        before_action :authenticate_user!

        def queue
          if params[:id].present?
            @record = DataStore.branch_loans_stats.where(id: params[:id]).first
          else
            if params[:branch_id].present? && params[:as_of].present?
              @record = DataStore.branch_loans_stats.where(
                          "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                          params[:branch_id],
                          params[:as_of]
                        ).first
            end
          end

          if @record.blank?
            @branch = Branch.find(params[:branch_id])
            @as_of  = params[:as_of].to_date

            @record = DataStore.create!(
                        meta: {
                          branch_id: @branch.id,
                          branch_name: @branch.name,
                          as_of: @as_of,
                          data_store_type: "BRANCH_LOANS_STATS",
                          include_centers: false
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          args = {
            record: @record
          }

          ProcessBranchLoansStats.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
