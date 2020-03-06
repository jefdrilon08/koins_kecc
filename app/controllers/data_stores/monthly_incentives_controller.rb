module DataStores
  class MonthlyIncentivesController < DataStoreController
    def show
      @record = DataStore.monthly_incentives.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/monthly_incentives"
      end
    end
  end
end
