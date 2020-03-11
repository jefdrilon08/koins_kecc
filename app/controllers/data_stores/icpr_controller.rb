module DataStores
  class IcprController < DataStoreController
    def show
      @record = DataStore.icpr.where(id: params[:id]).first
      @data   = @record.data.with_indifferent_access

      @equity_interest_rate = @data[:equity_interest_rate]
      @savings_rate         = @data[:savings_rate]
      @cbu_rate             = @data[:cbu_rate]

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/icpr"
      end
    end
  end
end
