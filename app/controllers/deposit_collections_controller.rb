class DepositCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @deposit_collections = ReadOnlyDepositCollection
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id)) 

    if params[:start_date].present? and params[:end_date].present?
      @deposit_collections = @deposit_collections.where("collection_date >= ?  and collection_date <= ?", params[:start_date], params[:end_date] )
    end

    if params[:branch_id].present?
      @branch   = ReadOnlyBranch.find(params[:branch_id])
      @deposit_collections = @deposit_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = ReadOnlyCenter.find(params[:center_id])
    
      @deposit_collections = @deposit_collections.where(center_id: @center.id)

    end

    if params[:status].present?
      @status = params[:status]
      @deposit_collections = @deposit_collections.where(status: @status)
    end
    
    @deposit_collections = @deposit_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)

    @subheader_items = [
      { text: "Cash Management" },
      { text: "Deposits" }
    ]

    @subheader_side_actions = [
      { id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
    ]
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

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: deposit_collections_path,
        text: "Deposits"
      },
      {
        text: "Deposit: #{@deposit_collection.id}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-print-accounting-entry",
        link: "#",
        class: "fa fa-print",
        text: "Print Accounting Entry"
      },
      {
        id: "btn-print",
        link: "#",
        class: "fa fa-print",
        text: "Print"
      }
    ]
    @subheader_side_actions << {
      link: "#",
      class: "fa fa-print-thermal",
      id: "btn-thermal",
      text: "Print Thermal"
    }

    if @deposit_collection.pending?
      @subheader_side_actions << {
        id: "btn-load-branch",
        link: "#",
        class: "fa fa-sync",
        text: "Load Branch"
      }

      @subheader_side_actions << {
        id: "btn-load-center",
        link: "#",
        class: "fa fa-sync",
        text: "Load Center"
      }
    end

    if @deposit_collection.pending? && helpers.sbk_mis_bk_oas?
      @subheader_side_actions << {
        class: "fa fa-times",
        link: deposit_collection_path(@deposit_collection.id),
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
      }
    end

    if @deposit_collection.pending? && !@deposit_collection.finalized? && (current_user.roles.include?("REMOTE-BK") || current_user.roles.include?("MIS") || current_user.roles.include?("REMOTE-FM"))
      @subheader_side_actions << {
        id: "btn-finalize",
        class: "fa fa-check",
        link: "#",
        text: "Finalize"
      }
    end

    if @deposit_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK"))
      if Settings.activate_microinsurance and @deposit_collection.finalized?
        @subheader_side_actions << {
          id: "btn-approve",
          class: "fa fa-check",
          link: "#",
          text: "Approve"
        }
      else
        @subheader_side_actions << {
          id: "btn-approve",
          class: "fa fa-check",
          link: "#",
          text: "Approve"
        }
      end
    end

    @payload = {
      id: @deposit_collection.id,
      centers: helpers.fetch_centers(@deposit_collection.branch)
    }
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


    CSV.foreach(file.path, headers: true, encoding: 'windows-1251:utf-8') do |row|
      deposit_collection = row.to_hash
      @errors = DepositCollections::ValidateDepositFromCsvFile.new(deposit_collection: deposit_collection, config: config).execute!
    end

    if @errors[:messages].any?
      redirect_to upload_deposit_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
    else
      @deposit_collection = DepositCollections::LoadDepositFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully upload deposit."
      redirect_to deposit_collection_path(@deposit_collection)
    end  
  end
end
