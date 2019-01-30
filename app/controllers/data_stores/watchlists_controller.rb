module DataStores
  class WatchlistsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.watchlists.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.watchlists.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/watchlists"
      end
    end

    def destroy
      @record = DataStore.watchlists.where(id: params[:id]).first
      @record.destroy! 

      redirect_to "/data_stores/watchlists"
    end
  end
end
