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
end
