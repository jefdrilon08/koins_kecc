module DataStores
  class IcprController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.icpr.select("*")

      @records  = @records.order(
                    "meta->>'year' DESC" 
                  ).page(params[:page]).per(20)
    end

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

    def destroy
      @record = DataStore.icpr.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/icpr"
    end
  end
end
