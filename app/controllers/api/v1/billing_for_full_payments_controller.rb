module Api
  module V1
    class BillingForFullPaymentsController < ApplicationController
      
      def create
          branch_id = params[:branch_id]
          center_id = params[:center_id]  
          collection_date = params[:collection_date]
          
          billing_header = []
          Settings.loan_products.each do |a|
            if  a[:for_unearned_interest] == true
              billing_header << a[:loan_product_id]
            end
          end
          billing_header << "WP"
          meta = {
              branch_id: branch_id,
              center_id: center_id,
              collection_date: collection_date,
              billing_header: billing_header,
              data_store_type: "Billing"
          }
          a = DataStore.create!(meta: meta)
          raise a.inspect
      end

    end
  end
end
