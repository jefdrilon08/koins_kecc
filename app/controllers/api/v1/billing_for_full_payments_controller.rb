module Api
  module V1
    class BillingForFullPaymentsController < ApplicationController
      
      def create
  
          branch_id = params[:branch_id]
          center_id = params[:center_id]  
          collection_date = params[:collection_date]
            


          config = {
            branch: branch_id,
            center: center_id,
            collection_date: collection_date

          }

          



          record = ::BillingForFullPayments::SaveBillingForFullPayments.new(
                                                                                config: config
                                                                              ).execute!
             
      end

      def update_amount
          loan_id         = params[:loan_id]
          loan_product_id = params[:loan_product_id]
          data_store_id   = params[:data_store_id]
          loan_amount     = params[:loan_amount]
          
          config = {
            loan_id:          loan_id,
            loan_product_id:  loan_product_id,
            data_store_id:    data_store_id,
            loan_amount:      loan_amount,
           }
          
          record = ::BillingForFullPayments::UpdateBillingAmount.new(
                                                                      config: config
                                                                    ).execute!

           
      end

    end
  end
end
