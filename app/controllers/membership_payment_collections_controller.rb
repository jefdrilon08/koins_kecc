class MembershipPaymentCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @membership_payment_collections = MembershipPaymentCollection
      .includes(:branch, :center)
      .where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @membership_payment_collections = @membership_payment_collections.where("collection_date >= ?  and collection_date <= ?", params[:start_date], params[:end_date] )
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @membership_payment_collections = @membership_payment_collections.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center = Center.find(params[:center_id])
    
      @membership_payment_collections = @membership_payment_collections.where(center_id: @center.id)

    end

    if params[:status].present?
      @status = params[:status]
      @membership_payment_collections = @membership_payment_collections.where(status: @status)
    end

    @membership_payment_collections = @membership_payment_collections.order("status DESC, collection_date DESC").page(params[:page]).per(LIST_PAGE_SIZE)
  end

  def show
    @membership_payment_collection  = MembershipPaymentCollection.find(params[:id])
    @data     = @membership_payment_collection.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'membership_payment_collection_id' = ?",
                        @membership_payment_collection.id
                      ).order("created_at DESC")
  end

  def destroy
    @membership_payment_collection  = MembershipPaymentCollection.find(params[:id])

    if @membership_payment_collection.pending?
      @membership_payment_collection.destroy!

      redirect_to membership_payment_collections_path
    else
      redirect_to membership_payment_collection_path(@membership_payment_collection)
    end
  end
end
