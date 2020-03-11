class SavingsInsuranceTransferCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @savings_insurance_transfer_collections = SavingsInsuranceTransferCollection.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.where(status: @status)
    end

    @savings_insurance_transfer_collections = @savings_insurance_transfer_collections.order("status DESC, collection_date DESC").page(params[:page]).per(100)
  end

  def show
    @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.find(params[:id])

    if @savings_insurance_transfer_collection.processing?
      redirect_to savings_insurance_transfer_collections_path
    end

    @accounting_entry_hash                  = @savings_insurance_transfer_collection.data.with_indifferent_access[:accounting_entry]

    @members  = Member.active.where(
                  center_id: @savings_insurance_transfer_collection.center.id
                ).where.not(
                  id: @savings_insurance_transfer_collection.member_ids
                ).order("last_name ASC")

    @records  = @savings_insurance_transfer_collection.data.with_indifferent_access["records"]
  end

  def destroy
    @savings_insurance_transfer_collection  = SavingsInsuranceTransferCollection.find(params[:id])
    @savings_insurance_transfer_collection.destroy!

    redirect_to savings_insurance_transfer_collections_path
  end
end
