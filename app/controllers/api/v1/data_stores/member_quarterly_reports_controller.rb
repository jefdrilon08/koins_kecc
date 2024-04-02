module Api
  module V1
    module DataStores
      class MemberQuarterlyReportsController < ActionController::Base
        before_action :authenticate_user!

        def queue
          @data_store_type  = "Member Quarterly Reports"
          @as_of            = params[:as_of].try(:to_date) || Date.today

          @record = DataStore.member_quarterly_reports.where(
                      # "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                      "CAST(meta->>'as_of' AS date) = ?",
                      # @branch.id,
                      @as_of
                    ).first

          if @record.blank?
            @record = DataStore.create!(
                        meta: {
                          # branch_id: @branch.id,
                          # branch_name: @branch.name,
                          # branch: {
                          #   id: @branch.id,
                          #   name: @branch.name
                          # },
                          as_of: @as_of,
                          data_store_type: @data_store_type
                        },
                        data: {
                          status: "processing"
                        }
                      )

            args  = {
              record: @record,
              data_store_type: @data_store_type
            }

            ProcessMemberQuarterlyReports.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
