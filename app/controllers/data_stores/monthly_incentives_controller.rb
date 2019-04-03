module DataStores
  class MonthlyIncentivesController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.monthly_incentives.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.monthly_incentives.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/monthly_incentives"
      end
    end

    def destroy
      @record = DataStore.monthly_incentives.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/monthly_incentives"
    end
  end
end
