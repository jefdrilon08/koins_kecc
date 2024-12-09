module Api
  module V1
    module DataStores
      class HolidayRecordsController < ApiController
        # before_action :set_holiday, only: [:show, :update, :destroy]

        def create
          config = {
            holiday_name: params[:holiday_name],
            holiday_date: params[:holiday_date],
            status: params[:status]
          }
          result  = ::HolidayRecords::Create.new(config:config).execute!
          render json: {message: result}
        end

        
        def update
          config = {
            holiday_record_id: params[:id],
            holiday_name: params[:holiday_name],
            holiday_date: params[:holiday_date],
            status: params[:status]
          }
          result  = ::HolidayRecords::Update.new(config:config).execute!
          render json: {message: result}
        end

        def delete
          config = { holiday_id: params[:holiday_id] }

          begin
            result = ::HolidayRecords::Delete.new(config: config).execute!
            render json: { message: result[:message] }
          rescue => e
            render json: { error: e.message }, status: :not_found
          end
        end

       end
    end
  end
end