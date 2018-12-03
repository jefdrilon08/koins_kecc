module DataStores
  class CenterStatementsController < ApplicationController
    before_action :authenticate_user!

    def index
      @centers  = Center.where(id: @branches.pluck(:center_id))
      @records  = DataStore.center_statements.where(
                    "meta->>'center'->>'id' IN (?)",
                    @centers.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'start_date' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.center_statements.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/center_statements"
      end
    end

    def destroy
      @record = DataStore.center_statements.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/center_statements"
    end
  end
end
