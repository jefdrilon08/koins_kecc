class MembershipPaymentCollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @membership_payment_collections = MembershipPaymentCollection.select("*")

    @membership_payment_collections = @membership_payment_collections.order("status DESC, collection_date DESC").page(params[:page]).per(20)
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
