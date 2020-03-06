module DataStores
  class SoaExpensesController < DataStoreController
    def show
      @record = DataStore.soa_expenses.where(id: params[:id]).first
      @meta   = @record.meta.with_indifferent_access
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/soa_expenses"
      end
    end
  end
end
