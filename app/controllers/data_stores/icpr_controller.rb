module DataStores
  class IcprController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.icpr.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.icpr.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/icpr"
      end
    end

    def destroy
      @record = DataStore.icpr.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/icpr"
    end
  end
end
