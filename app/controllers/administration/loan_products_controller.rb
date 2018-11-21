module Administration
  class LoanProductsController < ApplicationController
    before_action :authenticate_user!

    def index
      @loan_products  = LoanProduct.select("*").order("name ASC")
    end
  end
end
