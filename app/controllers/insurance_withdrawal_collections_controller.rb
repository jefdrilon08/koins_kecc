class InsuranceWithdrawalCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_withdrawal_collections = InsuranceWithdrawalCollection.select("*")

    @insurance_withdrawal_collections = @insurance_withdrawal_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @insurance_withdrawal_collection = InsuranceWithdrawalCollection.find(params[:id])
    @data               = @insurance_withdrawal_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'insurance_withdrawal_collection_id' = ?",
                        @insurance_withdrawal_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @insurance_withdrawal_collection  = InsuranceWithdrawalCollection.find(params[:id])

    if @insurance_withdrawal_collection.pending?
      @insurance_withdrawal_collection.destroy!

      redirect_to insurance_withdrawal_collections_path
    else
      redirect_to insurance_withdrawal_collection_path(@insurance_withdrawal_collection)
    end
  end
end
