module Administration
  class LoanProductsController < ApplicationController
    before_action :authenticate_user!

    def index
      @loan_products  = LoanProduct.select("*").order("name ASC")
    end

    def show
      @loan_product = LoanProduct.find(params[:id])
    end

    def new
      @loan_product = LoanProduct.new
    end

    def create
      @loan_product = LoanProduct.new(loan_product_params)

      if @loan_product.save
        redirect_to administraiton_loan_product_path(@loan_product)
      else
        render :new
      end
    end

    def edit
      @loan_product = LoanProduct.find(params[:id])
    end

    def update
      @loan_product = LoanProduct.find(params[:id])

      if @loan_product.update(loan_product_params)
      else
      end
    end

    private

    def loan_product_params
      params.require(:loan_product).permit!
    end
  end
end
