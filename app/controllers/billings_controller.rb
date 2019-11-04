class BillingsController < ApplicationController
  before_action :authenticate_user!
  
    
  def index
    @billings = Billing.select("*").where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @billings = @billings.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = Branch.find(params[:branch_id])
      @billings = @billings.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = Center.find(params[:center_id])
      @billings = @billings.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @billings = @billings.where(status: @status)
    end

    @billings = @billings.order("status DESC, collection_date DESC").page(params[:page]).per(100)
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

  def excel
    render json: {download_url: "#{billing_download_excel_path(billing: params[:id])}"} 
  end
 
  def billing_excel
  
    billing_excel = ::Billings::BillingDownloadExcel.new(billing: params[:billing]).execute!
    filename = "billing.xlsx"
    billing_excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end

end
