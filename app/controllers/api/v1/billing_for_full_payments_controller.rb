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

    end
  end
end
