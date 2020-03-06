module DataStores
  class XWeeksToPayController < DataStoreController
    def show
      @record = DataStore.x_weeks_to_pay.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/x_weeks_to_pay"
      end
    end
  end
end
