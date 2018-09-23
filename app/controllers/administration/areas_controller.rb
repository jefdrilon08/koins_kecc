module Administration
  class AreasController < ApplicationController
    before_action :authenticate_user!

    def index
      @areas  = Area.select("*")
    end

    def new
      @area = Area.new
    end

    def create
      @area = Area.new(area_params)

      if @area.save
        redirect_to administration_area_path(@area)
      else
        render :new
      end
    end

    def edit
      @area = Area.find(params[:id])
    end

    def update
      @area = Area.find(params[:id])

      if @area.update(area_params)
        redirect_to administration_area_path(@area)
      else
        render :edit
      end
    end

    def show
      @area = Area.find(params[:id])
    end

    private

    def load_user!
      @area = Area.find(params[:id])
    end

    def area_params
      params.require(:area).permit!
    end
  end
end
