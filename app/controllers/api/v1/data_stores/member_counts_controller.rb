module Api
  module V1
    module DataStores
      class MemberCountsController < ApiController
        before_action :authenticate_app_request!
        before_action :authenticate_core_user!

        def queue
          @data_store_type  = "MEMBER_COUNTS"
          @as_of            = params[:as_of].try(:to_date) || Date.today
          @branch           = ReadOnlyBranch.find(params[:branch_id])

          @record = ReadOnlyDataStore.member_counts.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                      @branch.id,
                      @as_of
                    ).first

          if @record.blank?
            @record = DataStore.create!(
                        status: "processing",
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
          else
            @record.update!(status: "processing")
          end

          args  = {
            record_id: @record.id,
            data_store_type: @data_store_type
          }

          ProcessBranchMemberCounts.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
