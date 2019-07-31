module DataStores
  class ManualAgingController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.manual_aging.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.manual_aging.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/manual_aging"
      end
    end

    def destroy
      @record = DataStore.manual_aging.where(id: params[:id]).first
      @record.destroy! 

      redirect_to "/data_stores/manual_aging"
    end
  end
end
