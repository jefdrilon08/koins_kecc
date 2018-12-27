class MonthlyClosingCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @monthly_closing_collections  = MonthlyClosingCollection.where(
                                      branch_id: @branches.pluck(:id)
                                    ).order("closing_date DESC")

    @interest_member_accounts = Settings.interest_member_accounts

    if @interest_member_accounts.blank?
      raise "Settings not found: interest_member_accounts"
    end

    @account_subtypes = @interest_member_accounts.map{ |o|
                          o.account_subtype
                        }
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
