module Api
  module V1
    class AccruedPaymentCollectionsController < ApplicationController
    	def create
    		collection_date = params[:collection_date].try(:to_date)
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

        def update_transaction
          data_store_id       = params[:data_store_id]
          member_id           = params[:member_id].to_i
          member_account_id   = params[:member_account_id].to_i
          loan_amount         = params[:loan_amount].to_f
          config              = {
                                data_store_id: data_store_id,
                                member_id: member_id,
                                member_account_id: member_account_id,
                                loan_amount: loan_amount                     
                                }
          update_transaction = ::AccruedPaymentCollections::UpdateTransaction.new(
                                            config: config
                                          ).execute!

          #billing = AccruedBilling.find(data_store_id)
          #billing_data = billing.data.with_indifferent_access
          #billing_data[:member_data][member_id][:loan_data][member_account_id][:amount] = loan_amount
          #billing.update(data: billing_data)
           
        end

    end
  end
end
