module Api
  module V1
    module Adjustments
      class MakePaymentsController < ApiController
        before_action :authenticate_user!
        def approve
          @make_payment_details = MakePayment.find(params[:make_payment_id])
          @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @make_payment_details.member.branch
                        }
                      ).execute!
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
              user: current_user,
              current_date: @current_date

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
