class TimeDepositCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @time_deposit_collections = TimeDepositCollection
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id))

    @time_deposit_collections = @time_deposit_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @time_deposit_collection = TimeDepositCollection.find(params[:id])

    if @time_deposit_collection.processing?
      redirect_to time_deposit_collections_path
    else
      @data           = @time_deposit_collection.data.with_indifferent_access
      @centers        = @time_deposit_collection.branch.centers.order("name ASC")

      @activity_logs  = ActivityLog.where(
                          "data ->> 'time_deposit_collection_id' = ?",
                          @time_deposit_collection.id
                        ).order("created_at DESC")
    end
  end

  def destroy
    @time_deposit_collection  = TimeDepositCollection.find(params[:id])

    if @time_deposit_collection.pending?
      @time_deposit_collection.destroy!

      redirect_to time_deposit_collections_path
    else
      redirect_to time_deposit_collection_path(@time_deposit_collection)
    end
  end
end
