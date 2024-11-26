module Api
  module V1
    module DataStores
      class HolidaysController < ApiController
        before_action :set_holiday, only: [:show, :update, :destroy]

        def index
          holidays = Holiday.all
          render json: holidays
        end
        
        def show
          render json: @holiday
        end

        def create
          holiday = Holiday.new(holiday_params)
        
          if holiday.save
            render json: { message: 'Holiday successfully created', status: 200, data: { holiday: holiday } }, status: :created
          else
            render json: { errors: holiday.errors.full_messages }, status: :unprocessable_entity
          end
        end

        
        def update
          if @holiday.update(holiday_params)
            render json: @holiday
          else
            render json: { errors: @holiday.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @holiday.destroy
          head :no_content
        end

        private

        def set_holiday
          @holiday = Holiday.find_by(id: params[:id])
          unless @holiday
            render json: { error: 'Holiday not found' }, status: :not_found
          end
        end

        def holiday_params
          params.require(:holiday).permit(:holiday_name, :holiday_date, :status)
        end
      end
    end
  end
end