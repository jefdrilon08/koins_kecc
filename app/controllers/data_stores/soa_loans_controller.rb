module DataStores
  class SoaLoansController < DataStoreController
    def show
      @record = DataStore.soa_loans.where(id: params[:id]).first
      @meta   = @record.meta.with_indifferent_access
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/soa_loans"
      end
    end
  end
end
