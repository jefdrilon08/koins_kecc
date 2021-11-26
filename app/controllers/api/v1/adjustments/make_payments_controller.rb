module Api
  module V1
    module Adjustments
      class MakePaymentsController < ApplicationController
        def approve
          @make_payment_details = MakePayment.find(params[:make_payment_id])
          config = {
                      make_payment: @make_payment_details,
                      user: current_user
                    }
          @data = ::Adjustments::MakePayments::ApproveMakePayments.new(config: config).execute!
                  
          render json: { id: @make_payment_details.id }
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
