module Administration
  class CentersController < ApplicationController
    before_action :authenticate_user!

    def index
      @centers  = Center.select("*").where(branch_id: @branches.pluck(:id))
      
    end

    def new
      @center = Center.new
    end

    def create
      @center = Center.new(center_params)

      if @center.save
        redirect_to administration_center_path(@center)
      else
        render :new
      end
    end

    def edit
      @center = Center.find(params[:id])
    end

    def update
      @center = Center.find(params[:id])

      if @center.update(center_params)
        redirect_to administration_center_path(@center)
      else
        render :edit
      end
    end

    def show
      @center = Center.find(params[:id])
    end

    def destroy
      @center = Center.find(params[:id])
      @center.destroy!
      flash[:success] = "Successfully removed center"
      redirect_to administration_center_path
    end

    private

    def load_user!
      @center = Center.find(params[:id])
    end

    def center_params
      params.require(:center).permit!
    end
  end
end
