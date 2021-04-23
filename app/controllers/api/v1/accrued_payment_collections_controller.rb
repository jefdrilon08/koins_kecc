module Api
  module V1
    class AccruedPaymentCollectionsController < ApplicationController
    	def create
    		collection_date   = params[:collection_date].try(:to_date)
        	branch_id       = params[:branch_id]
        	center_id       = params[:center_id]
          member_id       = params[:member_id]


        	config  = {
          		collection_date: collection_date,
          		branch_id: branch_id,
          		center_id: center_id,
              member_id: member_id,
          		user: current_user
        	}

        	#billing = AccruedBilling.new(
                      #collection_date: collection_date,
                      #branch_id: branch_id,
                      #center_id: center_id
                      #)

          #billing.save!
          accrued_payment_collection = ::AccruedPaymentCollections::CreateAccruedPaymentCollection.new(
                                            config: config
                                          ).execute!
          render json: { message: "ok", id: accrued_payment_collection.id }
    	end
    end
  end
end