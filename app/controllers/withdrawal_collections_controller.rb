class WithdrawalCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @withdrawal_collections = WithdrawalCollection.select("*")

    @withdrawal_collections = @withdrawal_collections.order("collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @withdrawal_collection = WithdrawalCollection.find(params[:id])
    @data               = @withdrawal_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'withdrawal_collection_id' = ?",
                        @withdrawal_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @withdrawal_collection  = WithdrawalCollection.find(params[:id])

    if @withdrawal_collection.pending?
      @withdrawal_collection.destroy!

      redirect_to withdrawal_collections_path
    else
      redirect_to withdrawal_collection_path(@withdrawal_collection)
    end
  end
end
