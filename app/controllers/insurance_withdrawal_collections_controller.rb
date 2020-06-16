class InsuranceWithdrawalCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_withdrawal_collections = InsuranceWithdrawalCollection.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @insurance_withdrawal_collections = @insurance_withdrawal_collections.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @insurance_withdrawal_collections = @insurance_withdrawal_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @insurance_withdrawal_collections = @insurance_withdrawal_collections.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @insurance_withdrawal_collections = @insurance_withdrawal_collections.where(status: @status)
    end

    @insurance_withdrawal_collections = @insurance_withdrawal_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Insurance Withdrawals"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Transaction"
      }
    ]
  end

  def show
    @insurance_withdrawal_collection = InsuranceWithdrawalCollection.find(params[:id])
    @data               = @insurance_withdrawal_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'insurance_withdrawal_collection_id' = ?",
                        @insurance_withdrawal_collection.id
                      ).order("created_at DESC")

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: insurance_withdrawal_collections_path,
        text: "Insurance Withdrawals"
      },
      {
        text: "Record: #{@insurance_withdrawal_collection.id}"
      }
    ]

    @subheader_side_actions = []

    if @insurance_withdrawal_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK"))
      @subheader_side_actions << {
        link: insurance_withdrawal_collection_path(@insurance_withdrawal_collection),
        class: "fa fa-times",
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
      }

      @subheader_side_actions << {
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",
        text: "Approve"
      }
    end

    @payload = {
      id: @insurance_withdrawal_collection.id
    }
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
      insurance_withdrawal_collection = row.to_hash
      @errors = InsuranceWithdrawalCollections::ValidateInsuranceWithdrawalFromCsvFile.new(insurance_withdrawal_collection: insurance_withdrawal_collection, config: config).execute!
    end

    if @errors[:messages].any?
      redirect_to upload_insurance_withdrawal_path
      flash[:error] = @errors[:messages]
    else
      @insurance_withdrawal_collection = InsuranceWithdrawalCollections::LoadInsuranceWithdrawalFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully upload deposit."
      redirect_to insurance_withdrawal_collection_path(@insurance_withdrawal_collection)
    end
  end
end
