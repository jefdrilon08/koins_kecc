module Accounting
  class YearEndClosingsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records  = DataStore.year_end_closings.where(
                    "meta->>'branch_id' IN (?)",
                    @branches.pluck(:id)
                  )

      @records  = @records.order(
                    "CAST(meta->>'closing_date' AS date) DESC"
                  ).page(params[:page]).per(20)
    end

    def show
      @record = DataStore.year_end_closings.find(params[:id])
      @meta   = @record.meta.with_indifferent_access
      @branch = Branch.find(@meta[:branch_id])
      @year   = @meta[:year]

      @data = @record.data.with_indifferent_access
    end

    def destroy
      @record = DataStore.year_end_closings.find(params[:id])
      @record.destroy!

      redirect_to accounting_year_end_closings_path
    end
  end
end
