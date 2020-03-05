module DataStores
  class BranchLoansStatsController < ApplicationController
    before_action :authenticate_user!

    def index
      @records = DataStore
        .select("status, meta->>'branch_name' AS branch_name, meta->>'as_of' AS as_of, created_at, updated_at")
        .repayment_rates.where("meta->>'branch_id' IN (?)", @branches.pluck(:id))
        .order("CAST(meta->>'as_of' AS date) DESC").page(params[:page]).per(20)
    end

    def show
      @record = DataStore.repayment_rates.where(id: params[:id]).first

      @data = ::DataStores::BuildBranchLoanStatsFromRr.new(
                rr_data: @record.data.with_indifferent_access
              ).execute!

      @officer_data = ::DataStores::BuildBranchLoanStatsPerOfficerFromRr.new(
                        rr_data: @record.data.with_indifferent_access
                      ).execute!

      if @record.blank? or @record.processing?
        redirect_to "/data_stores/branch_loans_stats"
      end
    end

    def destroy
      @record = DataStore.repayment_rates.where(id: params[:id]).first
      @record.destroy! 
      redirect_to "/data_stores/branch_loans_stats"
    end
  end
end
