class BillingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @billings = Billing.select("*")

    @billings = @billings.order("collection_date DESC").page(params[:page]).per(20)
  end

  def show
    @billing  = Billing.find(params[:id])
    @data     = @billing.data.with_indifferent_access

    @activity_logs  = ActivityLog.where(
                        "data ->> 'billing_id' = ?",
                        @billing.id
                      ).order("created_at DESC")
  end

  def destroy
    @billing  = Billing.find(params[:id])

    if @billing.pending?
      @billing.destroy!

      redirect_to billings_path
    else
      redirect_to billing_path(@billing)
    end
  end
end
