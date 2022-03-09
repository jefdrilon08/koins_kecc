class CommissionCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @commission_collections = CommissionCollection.all.order(date_prepared: :desc)

    if params[:start_date].present? and params[:end_date].present? and params[:start_date] <= params[:end_date]
      @commission_collections  = @commission_collections.where(
                                        "date_prepared >= ? AND date_prepared <= ?",
                                        params[:start_date],
                                        params[:end_date]
                                      )
    end

    if params[:status].present?
      @status                  = params[:status]
      @commission_collections  = @commission_collections.where(status: params[:status])
    end

    @commission_collections  = @commission_collections.page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Commission Collections"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new",
        link: "#",
        class: "fa fa-plus",
        text: "New Commission Collection"
      }
    ]
  end

  def show
    @commission_collection = CommissionCollection.find(params[:id])
    
    if @commission_collection.data.present?
      @commission_collection_data = @commission_collection.data.with_indifferent_access
    end

    if !@commission_collection_data.nil?
      @accounting_entry_data = @commission_collection_data[:accounting_entry]
    end

    if @commission_collection.processing?
      redirect_to commission_collections_path
    end

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: commission_collections_path,
        text: "Commission Collections"
      },
      {
        text: "#{@commission_collection.date_prepared.strftime("%b %d, %Y")} - #{@commission_collection.status}"
      }
    ]

    @subheader_side_actions = []

    if @commission_collection.pending?
      @subheader_side_actions << {
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",
        text: "Approve"
      }
    end

    if @commission_collection.pending? || @commission_collection.error?
      @subheader_side_actions << {
        link: commission_collection_path(@commission_collection),
        class: "fa fa-times",
        text: "Delete",
        data: { method: :delete, confirm: "Are you sure?" }
      }
    end

    @payload = {
      id: @commission_collection.id
    }
  end

  def destroy
    @commission_collection = CommissionCollection.find(params[:id])

    if @commission_collection.pending? || @commission_collection.error?
      @commission_collection.destroy!

      redirect_to commission_collections_path
    else
      redirect_to commission_collection_path(@commission_collection)
    end
  end
end
