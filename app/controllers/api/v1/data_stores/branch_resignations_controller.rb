module Api
  module V1
    module DataStores
      class BranchResignationsController < ActionController::Base
        before_action :authenticate_user!

        def fetch
          @record = DataStore.branch_resignations.where(id: params[:id]).first

          if @record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            render json: @record
          end
        end

        def queue
          @data_store_type  = "BRANCH_RESIGNATIONS"
          @start_date       = params[:start_date].try(:to_date)
          @end_date         = params[:end_date].try(:to_date)
          @branch           = Branch.find(params[:branch_id])

          @record = DataStore.branch_resignations.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'start_date' AS date) = ? AND CAST(meta->>'end_date' AS date) = ?",
                      @branch.id,
                      @start_date,
                      @end_date
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
                          start_date: @start_date,
                          end_date: @end_date,
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

          ProcessBranchResignation.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
