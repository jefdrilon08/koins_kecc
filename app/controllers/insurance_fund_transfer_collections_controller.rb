class InsuranceFundTransferCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_fund_transfer_collections = InsuranceFundTransferCollection.select("*")

    @insurance_fund_transfer_collections = @insurance_fund_transfer_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])
    @data               = @insurance_fund_transfer_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'insurance_fund_transfer_collection_id' = ?",
                        @insurance_fund_transfer_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])

    if @insurance_fund_transfer_collection.pending?
      @insurance_fund_transfer_collection.destroy!

      redirect_to insurance_fund_transfer_collections_path
    else
      redirect_to insurance_fund_transfer_collection_path(@insurance_fund_transfer_collection)
    end
  end
end
