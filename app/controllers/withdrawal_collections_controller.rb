class WithdrawalCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @withdrawal_collections = WithdrawalCollection
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @withdrawal_collections = @withdrawal_collections.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @withdrawal_collections = @withdrawal_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @withdrawal_collections = @withdrawal_collections.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @withdrawal_collections = @withdrawal_collections.where(status: @status)
    end

    @withdrawal_collections = @withdrawal_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Withdrawals"
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
    @withdrawal_collection = WithdrawalCollection.find(params[:id])
    @data               = @withdrawal_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'withdrawal_collection_id' = ?",
                        @withdrawal_collection.id
                      ).order("created_at DESC")

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: withdrawal_collections_path,
        text: "Withdrawals"
      },
      {
        text: "Withdrawal: #{@withdrawal_collection.id}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-print",
        link: "#",
        class: "fa fa-print",
        text: "Print"
      }
    ]

    if @withdrawal_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK"))
      @subheader_side_actions << {
        link: withdrawal_collection_path(@withdrawal_collection.id),
        class: "fa fa-times",
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
      }

      @subheader_side_actions << {
        link: "#",
        class: "fa fa-check",
        id: "btn-approve",
        text: "Approve"
      }
    end
  end

  def destroy
    @withdrawal_collection  = WithdrawalCollection.find(params[:id])

    if @withdrawal_collection.pending?
      @withdrawal_collection.destroy!

      redirect_to withdrawal_collections_path
    else
      redirect_to withdrawal_collection_path(@withdrawal_collection)
    end
  end

  

end
