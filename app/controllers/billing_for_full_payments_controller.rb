class BillingForFullPaymentsController < ApplicationController
  def index
    
      @full_payment_billing =  DataStore.where(
                                                "meta ->> 'branch_id' IN (?) AND
                                                 meta ->> 'data_store_tpe' = ?",
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
      
  end
end
