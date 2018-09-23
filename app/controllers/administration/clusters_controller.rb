module Administration
  class ClustersController < ApplicationController
    before_action :authenticate_user!

    def index
      @clusters  = Cluster.select("*")
    end

    def new
      @cluster = Cluster.new
    end

    def create
      @cluster = Cluster.new(cluster_params) 

      if @cluster.save
        redirect_to administration_cluster_path(@cluster)
      else
        render :new
      end
    end

    def edit
      @cluster = Cluster.find(params[:id])
    end

    def update
      @cluster = Cluster.find(params[:id])

      if @cluster.update(cluster_params)
        redirect_to administration_cluster_path(@cluster)
      else
        render :edit
      end
    end

    def show
      @cluster = Cluster.find(params[:id])
    end

    private

    def load_user!
      @cluster = Cluster.find(params[:id])
    end

    def cluster_params
      params.require(:cluster).permit!
    end
  end
end
