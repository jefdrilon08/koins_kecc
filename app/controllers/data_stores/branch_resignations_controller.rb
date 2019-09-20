module DataStores
  class BranchResignationsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.branch_resignations.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.branch_resignations.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/branch_resignations"
      end
    end

    def destroy
      @record = DataStore.branch_resignations.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/branch_resignations"
    end
  end
end
