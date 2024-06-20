class TimeDepositCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @time_deposit_collections = TimeDepositCollection
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id))

    @time_deposit_collections = @time_deposit_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Time Deposits"
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

      @subheader_items = [
        {
          text: "Cash Management"
        },
        {
          is_link: true,
          path: time_deposit_collections_path,
          text: "Time Deposits"
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

      if @time_deposit_collection.pending? && (current_user.roles.include?("MIS") || current_user.roles.include?("BK") || current_user.roles.include?("SBK"))
        @subheader_side_actions << {
          class: "fa fa-times",
          link: time_deposit_collection_path(@time_deposit_collection),
          data: { method: :delete, confirm: "Are you sure?" },
          text: "Delete"
        }

        @subheader_side_actions << {
          id: "btn-approve",
          class: "fa fa-check",
          link: "#",
          text: "Approve"
        }

      end
      if @time_deposit_collection.approved?
        @subheader_side_actions << {
          id: "btn-thermal",
          class: "fa fa-check",
          link: "#",
          text: "Print Thermal"
        }
      end

      @payload = {
        id: @time_deposit_collection.id
      }
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
