class InsuranceMonthlyClosingCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @insurance_monthly_closing_collections = InsuranceMonthlyClosingCollection.includes(:branch).where(branch_id: @branches.pluck(:id)).order(closing_date: :desc)

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @insurance_monthly_closing_collections  = @insurance_monthly_closing_collections.where(
                                        branch_id: @branch.id
                                      )
    end

    if params[:start_date].present? and params[:end_date].present? and params[:start_date] <= params[:end_date]
      @insurance_monthly_closing_collections  = @insurance_monthly_closing_collections.where(
                                        "closing_date >= ? AND closing_date <= ?",
                                        params[:start_date],
                                        params[:end_date]
                                      )
    end

    if params[:status].present?
      @status                       = params[:status]
      @insurance_monthly_closing_collections  = @insurance_monthly_closing_collections.where(status: params[:status])
    end

    @insurance_interest_member_accounts = Settings.insurance_interest_member_accounts

    if @insurance_interest_member_accounts.blank?
      raise "Settings not found: interest_member_accounts"
    end

    @account_subtypes = @insurance_interest_member_accounts.map{ |o|
                          o.account_subtype
                        }

    @insurance_monthly_closing_collections  = @insurance_monthly_closing_collections.page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        text: "Insurance Monthly Closing Collections"
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
    @insurance_monthly_closing_collection = InsuranceMonthlyClosingCollection.find(params[:id])

    if @insurance_monthly_closing_collection.processing?
      redirect_to insurance_monthly_closing_collections_path
    end

    @subheader_items = [
      {
        text: "Cash Management"
      },
      {
        is_link: true,
        path: insurance_monthly_closing_collections_path,
        text: "Insurance Monthly Closing Collections"
      },
      {
        text: "Closing for #{@insurance_monthly_closing_collection.closing_date.strftime("%b %d, %Y")} - #{@insurance_monthly_closing_collection.branch} - #{@insurance_monthly_closing_collection.account_subtype}"
      }
    ]

    @subheader_side_actions = []

    if @insurance_monthly_closing_collection.pending?
      @subheader_side_actions << {
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",
        text: "Approve"
      }
    end

    if @insurance_monthly_closing_collection.pending? || @insurance_monthly_closing_collection.error?
      @subheader_side_actions << {
        link: insurance_monthly_closing_collection_path(@insurance_monthly_closing_collection),
        class: "fa fa-times",
        text: "Delete",
        data: { method: :delete, confirm: "Are you sure?" }
      }
    end

    @payload = {
      id: @insurance_monthly_closing_collection.id
    }
  end

  def destroy
    @insurance_monthly_closing_collection = InsuranceMonthlyClosingCollection.find(params[:id])

    if @insurance_monthly_closing_collection.pending? || @insurance_monthly_closing_collection.error?
      @insurance_monthly_closing_collection.destroy!

      redirect_to insurance_monthly_closing_collections_path
    else
      redirect_to insurance_monthly_closing_collection_path(@insurance_monthly_closing_collection)
    end
  end
end
