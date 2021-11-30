module Api
  module V1
    module Adjustments
      class MakePaymentsController < ApplicationController
        def approve
          @make_payment_details = MakePayment.find(params[:make_payment_id])
          #config = {
          #            make_payment: @make_payment_details,
          #            user: current_user
          #          }
          #@data = ::Adjustments::MakePayments::ApproveMakePayments.new(config: config).execute!

          #if errors[:messages].any?
          #  render json: errors, status: 404
          #else
            @make_payment_details.update(status: "processing")
            
            ProcessApproveMakePayments.perform_later({
              make_payment_details: @make_payment_details,
              user: current_user

            })

          #end
                  
          render json: { message: "ok" }
        end
        def destroy
          make_payment_id = params[:make_payment_id]
          make_payment_details = MakePayment.find(make_payment_id)
          make_payment_details.destroy!
          render json: { message: "ok"  }
          
        end
      end
    end
  end
end
