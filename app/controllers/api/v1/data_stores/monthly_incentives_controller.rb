module Api
  module V1
    module DataStores
      class MonthlyIncentivesController < ActionController::Base
        before_action :authenticate_user!

        def queue
          data_store_type = "MONTHLY_INCENTIVE"
          as_of           = params[:as_of].to_date
          month           = as_of.month
          year            = as_of.year
          branch          = Branch.find(params[:branch_id])
          as_of           = Date.new(year, month, -1)

          config  = {
            as_of: as_of,
            month: month,
            year: year,
            branch: branch
          }

          errors  = ::MonthlyIncentives::ValidateQueue.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            record  = DataStore.monthly_incentives.where(
                        "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                        branch.id,
                        as_of
                      ).first

            if record.blank?
              record  = DataStore.create!(
                          meta: {
                            branch_id: branch.id,
                            branch_name: branch.name,
                            branch: {
                              id: branch.id,
                              name: branch.name
                            },
                            month: month,
                            year: year,
                            as_of: as_of,
                            data_store_type: data_store_type
                          },
                          data: {
                            records:[],
                            status: "processing"
                          }
                        )
            end

            args  = {
              data_store_id: record.id,
              user_id: current_user.id,
              branch_id: branch.id,
              year: year,
              month: month
            }

            ProcessMonthlyIncentive.perform_later(args)

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
