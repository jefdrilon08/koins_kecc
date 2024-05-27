module Api
  module V1
    module DataStores
      class AllowanceComputationReportController < ActionController::Base
        before_action :authenticate_user!

        def queue
          data_store_type = "ALLOWANCE_COMPUTATION"
          as_of           = params[:as_of].try(:to_date)
          record          = DataStore.create!(
                            meta: {
                              data_store_type: data_store_type,
                              as_of: as_of
                            }, 
                            data: {
                              records: [],
                              sato: [],
                              totals: {
                                total_par_month: 0.0,
                                total_par_year: 0.0,
                                total_par_greater: 0.0,
                                total_par: 0.0
                              },
                              status: "processing"
                            }
                          )
          args = {
            data_store_id: record.id,
            as_of: as_of
          }
          ProcessAllowanceReport.perform_later(args)
          #data_result = ::DataStores::GenerateAllowanceComputationReport.new(config: config).execute!
        end

        def fetch
          @record = DataStore.allowance_computation_report.find_by(id: params[:id])
          if @record.nil?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 404
          else
            render json: @record
          end
        end

      end
    end
  end
end
