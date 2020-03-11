module DataStores
  class MonthlyNewAndResignedController < DataStoreController
    def show
      @record = DataStore.monthly_new_and_resigned.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/monthly_new_and_resigned"
      end
    end
  end
end
