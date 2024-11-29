module Api
  module V1
    module DataStores
      class HolidayRecordsController < ApiController
        # before_action :set_holiday, only: [:show, :update, :destroy]

        # def index
        #   holidays = Holiday.all
        #   render json: holidays
        # end
        
        # def show
        #   render json: @holiday
        # end

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

      #   def destroy
      #     @holiday.destroy
      #     head :no_content
      #   end

      #   private

      #   def set_holiday
      #     @holiday = Holiday.find_by(id: params[:id])
      #     unless @holiday
      #       render json: { error: 'Holiday not found' }, status: :not_found
      #     end
      #   end

      #   def holiday_params
      #     params.require(:holiday).permit(:holiday_name, :holiday_date, :status)
      #   end
       end
    end
  end
end