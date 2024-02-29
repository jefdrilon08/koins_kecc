module Api
  module Members
    class LoanProductsController < ::Api::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        loan_products = LoanProduct.all.map{ |o|
          o.to_h
        }

        render json: { loan_products: loan_products }
      end
    end
  end
end
