class EquityWithdrawalCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @equity_withdrawal_collections = EquityWithdrawalCollection.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @equity_withdrawal_collections = @equity_withdrawal_collections.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @equity_withdrawal_collections = @equity_withdrawal_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @equity_withdrawal_collections = @equity_withdrawal_collections.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @equity_withdrawal_collections = @equity_withdrawal_collections.where(status: @status)
    end

    @equity_withdrawal_collections = @equity_withdrawal_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @equity_withdrawal_collection = EquityWithdrawalCollection.find(params[:id])
    @data                         = @equity_withdrawal_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'equity_withdrawal_collection_id' = ?",
                        @equity_withdrawal_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @equity_withdrawal_collection  = EquityWithdrawalCollection.find(params[:id])

    if @equity_withdrawal_collection.pending?
      @equity_withdrawal_collection.destroy!

      redirect_to equity_withdrawal_collections_path
    else
      redirect_to equity_withdrawal_collection_path(@equity_withdrawal_collection)
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
      equity_withdrawal_collection = row.to_hash
      @errors = EquityWithdrawalCollections::ValidateEquityWithdrawalFromCsvFile.new(equity_withdrawal_collection: equity_withdrawal_collection, config: config).execute!
    end

    if @errors[:messages].any?
      redirect_to upload_equity_withdrawal_path
      flash[:error] = @errors[:messages]
    else
      @equity_withdrawal_collection = EquityWithdrawalCollections::LoadEquityWithdrawalFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully upload deposit."
      redirect_to equity_withdrawal_collection_path(@equity_withdrawal_collection)
    end
  end
end
