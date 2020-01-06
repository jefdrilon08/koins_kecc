module DataStores
  class AccountingEntriesSummariesController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.accounting_entries_summaries.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'end_date' AS date) DESC" 
                  ).page(params[:page]).per(20)

      @current_date = Date.today
      @start_date   = Date.new(@current_date.year, @current_date.month, 1)
      @end_date     = Date.new(@current_date.year, @current_date.month, -1)
    end

    def show
      @record = DataStore.accounting_entries_summaries.where(id: params[:id]).first
      @meta   = @record.meta.with_indifferent_access
      @data   = @record.data.with_indifferent_access

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/accounting_entries_summaries"
      end
    end

    def destroy
      @record = DataStore.accounting_entries_summaries.where(id: params[:id]).first

      if !@record.processing?
        @record.destroy! 
        redirect_to "/data_stores/accounting_entries_summaries"
      else
        redirect_to "/data_stores/accounting_entries_summaries/#{@record.id}"
      end
    end
  end
end
