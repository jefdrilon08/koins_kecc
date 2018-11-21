module DataStores
  class BranchWithCentersLoansStatsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.branch_with_centers_loans_stats.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'as_of' AS date) DESC" 
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.branch_with_centers_loans_stats.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/branch_with_centers_loans_stats"
      end
    end

    def destroy
      @record = DataStore.branch_with_centers_loans_stats.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/branch_with_centers_loans_stats"
    end
  end
end
