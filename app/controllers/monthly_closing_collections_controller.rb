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
  end

  def show
    @monthly_closing_collection = MonthlyClosingCollection.find(params[:id])

    if @monthly_closing_collection.processing?
      redirect_to monthly_closing_collections_path
    end
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
