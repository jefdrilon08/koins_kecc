class InsuranceFundTransferCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_fund_transfer_collections = InsuranceFundTransferCollection.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @insurance_fund_transfer_collections = @insurance_fund_transfer_collections.where("collection_date >= ?  and collection_date <= ?", params[:start_date], params[:end_date] )
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @insurance_fund_transfer_collections = @insurance_fund_transfer_collections.where(branch_id: @branch.id)
    end

    if params[:status].present?
      @status = params[:status]
      @insurance_fund_transfer_collections = @insurance_fund_transfer_collections.where(status: @status)
    end

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
      insurance_fund_transfer_collection = row.to_hash
      @errors = InsuranceFundTransferCollections::ValidateFundTransferFromCsvFile.new(insurance_fund_transfer_collection: insurance_fund_transfer_collection, config: config).execute!
    end

    if @errors[:messages].size > 0
      redirect_to upload_deposit_path
      flash[:error] = @errors[:messages]
    else
      @insurance_fund_transfer_collection = InsuranceFundTransferCollections::LoadFundTransferFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully upload deposit."
      redirect_to insurance_fund_transfer_collection_path(@insurance_fund_transfer_collection)
    end  
  end


end
