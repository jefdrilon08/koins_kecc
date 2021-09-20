class BillingForFullPaymentsController < ApplicationController
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
  end

  
  def show
    @billing_data_store = DataStore.find(params[:id])
    @member_list = Member.where(center_id: @billing_data_store.meta["center_id"], status: "active")
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
end
