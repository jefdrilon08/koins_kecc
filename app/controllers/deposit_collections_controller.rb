class DepositCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @deposit_collections = DepositCollection.select("*").where(branch_id: @branches.pluck(:id)) 

    if params[:start_date].present? and params[:end_date].present?
      @deposit_collections = @deposit_collections.where("collection_date >= ?  and collection_date <= ?", params[:start_date], params[:end_date] )
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @deposit_collections = @deposit_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = Center.find(params[:center_id])
    
      @deposit_collections = @deposit_collections.where(center_id: @center.id)

    end

    if params[:status].present?
      @status = params[:status]
      @deposit_collections = @deposit_collections.where(status: @status)
    end
    
    @deposit_collections = @deposit_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @deposit_collection = DepositCollection.find(params[:id])

    if @deposit_collection.processing?
      redirect_to deposit_collections_path
    else
      @data               = @deposit_collection.data.with_indifferent_access
      @centers            = @deposit_collection.branch.centers.order("name ASC")

      @activity_logs  = ActivityLog.where(
                          "data ->> 'deposit_collection_id' = ?",
                          @deposit_collection.id
                        ).order("created_at DESC")
    end
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

  def upload
    file = params[:file]
    branch = Branch.find(params[:branch_id])
    paid_at = params[:paid_at]
    prepared_by = current_user
    
    config = {
      file: file,
      branch: branch,
      paid_at: paid_at,
      prepared_by: prepared_by
    }


    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      deposit_collection = row.to_hash
      @errors = DepositCollections::ValidateDepositFromCsvFile.new(deposit_collection: deposit_collection, config: config).execute!
    end

    if @errors[:messages].size > 0
      redirect_to upload_deposit_path
      flash[:error] = @errors[:messages]
    else
      @deposit_collection = DepositCollections::LoadDepositFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully upload deposit."
      redirect_to deposit_collection_path(@deposit_collection)
    end  
  end
end
