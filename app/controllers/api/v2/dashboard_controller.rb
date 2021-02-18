module Api
  module V2
    class DashboardController < ApiController
      before_action :authenticate_app_request!
      before_action :authenticate_core_user!

      def generate_daily_report
        branch_id = params[:branch_id]
        as_of     = params[:as_of].try(:to_date)

        cmd = ::Dashboard::ValidateGenerateDailyReport.new(
                config: {
                  branch_id: branch_id,
                  as_of: as_of
                }
              )

        cmd.execute!

        if cmd.errors[:full_messages].any?
          render json: cmd.errors, status: 400
        else
          branch = Branch.find(branch_id)

          ##### RR ####
          record  = DataStore.select("id, meta, status").where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ? AND meta->>'data_store_type' = ?",
                      branch_id,
                      as_of,
                      "REPAYMENT_RATES"
                    ).first

          if record.blank?
            record  = DataStore.create!(
                        meta: {
                          branch_id: branch.id,
                          branch_name: branch.name,
                          as_of: as_of,
                          data_store_type: "REPAYMENT_RATES"
                        },
                        data: {
                          status: "processing"
                        }
                      )
          else
            record.update!(status: "processing")
          end

          args = {
            id: record.id,
            data_store_type: "REPAYMENT_RATES"
          }

          ProcessRepaymentRates.perform_later(args)

          ##### MEMBER COUNTS ####
          record  = ReadOnlyDataStore
                    .select("id, status, as_of, meta")
                    .member_counts.where(
                      "meta->>'branch_id' = ? AND as_of = ?",
                      branch.id,
                      as_of
                    ).first

          if record.blank?
            record  = DataStore.create!(
                        status: "processing",
                        meta: {
                          branch_id: branch.id,
                          branch_name: branch.name,
                          branch: {
                            id: branch.id,
                            name: branch.name
                          },
                          as_of: as_of,
                          data_store_type: "MEMBER_COUNTS"
                        },
                        data: {
                          status: "processing"
                        }
                      )
          else
            record.update!(status: "processing")
          end

          args  = {
            record_id: record.id,
            data_store_type: "MEMBER_COUNTS"
          }

          ProcessBranchMemberCounts.perform_later(args)

          render json: { message: "ok" }
        end
      end
    end
  end
end
