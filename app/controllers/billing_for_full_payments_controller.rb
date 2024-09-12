class BillingForFullPaymentsController < ApplicationController
  before_action :authenticate_user!
  def index
    
      @full_payment_billing =  DataStore.where(
                                                "meta ->> 'branch_id' IN (?) AND
                                                 meta ->> 'data_store_type' = ?",
                                                 @branches.pluck(:id),
                                                "BILLING FOR FULL PAYMENT"
                                                 

                                              )
     
      @subheader_items = [
        {
          text: "Billing for Full Payment Loan"
        }
      ]
      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
      if params[:select_branch].present?
        @branch = ReadOnlyBranch.find(params[:select_branch])
        @full_payment_billing = @full_payment_billing.where("meta ->> 'branch_id' IN (?)", @branch.id)

      elsif params[:select_center].present?
        @center = ReadOnlyCenter.find(params[:select_center])
        @full_payment_billing = @full_payment_billing.where("meta ->> 'center_id' = ?",@center.id)
     

      elsif params[:status].present?
        @status = params[:status]
        @full_payment_billing = @full_payment_billing.where(status: @status)
      
      end 
  end

  
  def show
    @billing_data_store = DataStore.find(params[:id])
    @member_list = Member.where(center_id: @billing_data_store.meta["center_id"], status: "active")
      @subheader_items = [
        {
          text: "Billing for Full Payment Loan"
        }
      ]

      if @billing_data_store.pending? 
        @subheader_side_actions = [
         
          {
            id: "btn-approved",
            link: "#",
            class: "fa fa-check",
            text: "Approved",
            data: { data_store_id: params[:id] }
          },

          {
            id: "btn-checked",
            link: "#",
            class: "fa fa-check",
            text: "Check",
            data: { data_store_id: params[:id] }
          },
          
          {
            id: "btn-delete",
            link: "#",
            class: "fa fa-times",
            data: { method: :delete, confirm: "Are you sure?" },
            text: "Delete"
          }
        ]
      end
    @billing_header = []
      Settings.loan_products.each do |a|
        if  a[:for_unearned_interest] == true
          @billing_header << a[:loan_product_id]
        end
    end
    @billing_header
    
    

    @record = ::BillingForFullPayments::BuildAccountingEntry.new(
                                                                                full_payment_billing: @billing_data_store,
                                                                                current_user: current_user
                                                                              ).execute!
 
  end
  def destroy
    
    @billing_for_fullpayment = DataStore.find( params[:id])
    if @billing_for_fullpayment.pending?
      @billing_for_fullpayment.destroy!
      redirect_to billing_for_full_payments_path
    end




  end
end
