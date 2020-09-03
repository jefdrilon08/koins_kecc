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

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Insurance Fund Transfers"
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
    @insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(params[:id])
    @data               = @insurance_fund_transfer_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'insurance_fund_transfer_collection_id' = ?",
                        @insurance_fund_transfer_collection.id
                      ).order("created_at DESC")

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: insurance_fund_transfer_collections_path,
        text: "Insurance Fund Transfers"
      },
      {
        text: "Record: #{@insurance_fund_transfer_collection.id}"
      }
    ]

    @subheader_side_actions = []

    if @insurance_fund_transfer_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK") || current_user.roles.include?("REMOTE-BK") || current_user.roles.include?("REMOTE-FM"))
      @subheader_side_actions << {
        link: insurance_fund_transfer_collection_path(@insurance_fund_transfer_collection),
        class: "fa fa-times",
        text: "Delete",
        data: { method: :delete, confirm: "Are you sure?" }
      }
    end

    if @insurance_fund_transfer_collection.pending? && !@insurance_fund_transfer_collection.finalized? && (current_user.roles.include?("REMOTE-BK") || current_user.roles.include?("MIS") || current_user.roles.include?("REMOTE-FM"))
      @subheader_side_actions << {
        id: "btn-finalize",
        link: "#",
        class: "fa fa-check",
        text: "Finalize"
      }
    end

    if @insurance_fund_transfer_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK"))
      if Settings.activate_microinsurance and @insurance_fund_transfer_collection.finalized?
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
      else
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
      end
    end

    @payload = {
      id: @insurance_fund_transfer_collection.id,
      centers: helpers.fetch_centers(@insurance_fund_transfer_collection.branch)
    }
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

    raise "Under maintenance"
    
#    config = {
#      file: file,
#      branch: branch,
#      paid_at: paid_at,
#      prepared_by: prepared_by
#    }
#
#
#    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
#      insurance_fund_transfer_collection = row.to_hash
#      @errors = InsuranceFundTransferCollections::ValidateFundTransferFromCsvFile.new(insurance_fund_transfer_collection: insurance_fund_transfer_collection, config: config).execute!
#    end
#
#    if @errors[:messages].any?
#      redirect_to upload_fund_transfer_path
#      flash[:error] = @errors[:messages]
#    else
#      @insurance_fund_transfer_collection = InsuranceFundTransferCollections::LoadFundTransferFromCsvFile.new(config: config).execute!
#      flash[:success] = "Successfully upload fund transfer."
#      redirect_to insurance_fund_transfer_collection_path(@insurance_fund_transfer_collection)
#    end  
  end
end
