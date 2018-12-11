class DepositCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @deposit_collections = DepositCollection.select("*")

    @deposit_collections = @deposit_collections.order("collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @deposit_collection = DepositCollection.find(params[:id])
    @data               = @deposit_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'deposit_collection_id' = ?",
                        @deposit_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @deposit_collection  = DepositCollection.find(params[:id])

    if @deposit_collection.pending?
      @deposit_collection.destroy!

      redirect_to deposit_collections_path
    else
      redirect_to deposit_collection_path(@deposit_collection)
    end
  end
end
