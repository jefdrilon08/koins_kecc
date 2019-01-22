module DataStores
  class AccountingEntriesSummariesController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.accounting_entries_summaries.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'start_date' AS date) DESC" 
                  ).page(params[:page]).per(20)

      @current_date = Date.today
      @start_date   = Date.new(@current_date.year, @current_date.month, 1)
      @end_date     = Date.new(@current_date.year, @current_date.month, -1)
    end

    def show
      @record = DataStore.accounting_entries_summaries.where(id: params[:id]).first

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/accounting_:"
      end
    end

    def destroy
      @record = DataStore.branch_loans_stats.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/branch_loans_stats"
    end
  end
end
