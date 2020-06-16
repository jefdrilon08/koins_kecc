class MonthlyClosingCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @monthly_closing_collections = MonthlyClosingCollection
      .includes(:branch)
      .where(branch_id: @branches.pluck(:id))
      .order(closing_date: :desc)

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @monthly_closing_collections  = @monthly_closing_collections.where(
                                        branch_id: @branch.id
                                      )
    end

    if params[:start_date].present? and params[:end_date].present? and params[:start_date] <= params[:end_date]
      @monthly_closing_collections  = @monthly_closing_collections.where(
                                        "closing_date >= ? AND closing_date <= ?",
                                        params[:start_date],
                                        params[:end_date]
                                      )
    end

    if params[:status].present?
      @status                       = params[:status]
      @monthly_closing_collections  = @monthly_closing_collections.where(status: params[:status])
    end

    @interest_member_accounts = Settings.interest_member_accounts

    if @interest_member_accounts.blank?
      raise "Settings not found: interest_member_accounts"
    end

    @account_subtypes = @interest_member_accounts.map{ |o|
                          o.account_subtype
                        }

    @monthly_closing_collections  = @monthly_closing_collections.page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Monthly Closing Collections"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new",
        link: "#",
        class: "fa fa-plus",
        text: "New Collection"
      }
    ]
  end

  def show
    @monthly_closing_collection = MonthlyClosingCollection.find(params[:id])

    if @monthly_closing_collection.processing?
      redirect_to monthly_closing_collections_path
    end

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: monthly_closing_collections_path,
        text: "Monthly Closing Collections"
      },
      {
        text: "Closing for #{@monthly_closing_collection.closing_date.strftime("%b %d, %Y")} - #{@monthly_closing_collection.branch} - #{@monthly_closing_collection.account_subtype}"
      }
    ]

    @subheader_side_actions = []

    if @monthly_closing_collection.pending?
      @subheader_side_actions << {
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",
        text: "Approve"
      }
    end

    if @monthly_closing_collection.pending? || @monthly_closing_collection.error?
      @subheader_side_actions << {
        link: monthly_closing_collection_path(@monthly_closing_collection),
        class: "fa fa-times",
        text: "Delete",
        data: { method: :delete, confirm: "Are you sure?" }
      }
    end

    @payload = {
      id: @monthly_closing_collection.id
    }
  end

  def destroy
    @monthly_closing_collection = MonthlyClosingCollection.find(params[:id])

    if @monthly_closing_collection.pending? || @monthly_closing_collection.error?
      @monthly_closing_collection.destroy!

      redirect_to monthly_closing_collections_path
    else
      redirect_to monthly_closing_collection_path(@monthly_closing_collection)
    end
  end
end
