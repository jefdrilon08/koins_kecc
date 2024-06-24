module Api
  class LoanProductTypesController < ActionController::API
    def index
      loan_product_id = params[:loan_product_id]

      if loan_product_id.blank?
        payload = {
          errors: [
            "loan_product_id required"
          ]
        }

        render json: payload, status: :unprocessable_entity
      else
        payload = {
          loan_product_types: LoanProductTagging.where(loan_product_id: loan_product_id).map{ |o|
                                {
                                  id: o.id,
                                  name: o.name
                                }
                              }
        }

        render json: payload
      end
    end
  end
end
