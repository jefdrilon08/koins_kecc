module Api
  module V1
    module DataStores
      class BranchLoansStatsController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @data_store_type = params[:data_store_type] || "BRANCH_LOANS_STATS"
          @include_centers = false

          if @data_store_type == "BRANCH_WITH_CENTERS_LOANS_STATS"
            @include_centers = true
          end

          if params[:id].present?
            if @data_store_type == "BRANCH_WITH_CENTERS_LOANS_STATS"
              @record = DataStore.branch_with_centers_loans_stats.where(id: params[:id]).first
            else
              @record = DataStore.branch_loans_stats.where(id: params[:id]).first
            end
          else
            if params[:branch_id].present? && params[:as_of].present?
              if @data_store_type == "BRANCH_WITH_CENTERS_LOANS_STATS"
                @record = DataStore.branch_with_centers_loans_stats.where(
                            "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                            params[:branch_id],
                            params[:as_of]
                          ).first
              else
                @record = DataStore.branch_loans_stats.where(
                            "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                            params[:branch_id],
                            params[:as_of]
                          ).first
              end
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
                          data_store_type: @data_store_type,
                          include_centers: @include_centers
                        },
                        data: {
                          status: "processing"
                        }
                      )
          end

          @record.update!(status: "processing")

          args = {
            id: @record.id,
            data_store_type: @data_store_type,
            include_centers: @include_centers
          }

          ProcessBranchLoansStats.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
