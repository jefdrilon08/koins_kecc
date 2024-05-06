module Administration
  class LoanProductTaggingsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def new
      @loan_product = LoanProduct.find(params[:loan_product_id])
    
      @loan_product_type = LoanProductTagging.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_products_path,
          text: "Loan Products"
        },
        {
          is_link: true,
          path: administration_loan_product_path(@loan_product),
          text: @loan_product.to_s
        },
        {
          text: "New Loan Product Type"
        }
      ]
    end

    def create
      @loan_product = LoanProduct.find(params[:loan_product_id])
      
      @loan_product_type = LoanProductTagging.new(loan_product_type_params)
      
      @loan_product_type.loan_product = @loan_product

      if @loan_product_type.save
        redirect_to administration_loan_product_path(@loan_product)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_loan_products_path,
            text: "Loan Products"
          },
          {
            is_link: true,
            path: administration_loan_product_path(@loan_product),
            text: @loan_product.to_s
          },
          {
            text: "New Loan Product Type"
          }
        ]

        render :new
      end
    end

    def edit
      @loan_product = LoanProduct.find(params[:loan_product_id])
      @loan_product_type = LoanProductTagging.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_loan_products_path,
          text: "Loan Products"
        },
        {
          is_link: true,
          path: administration_loan_product_path(@loan_product),
          text: @loan_product.to_s
        },
        {
          text: "Edit #{@loan_product_type}"
        }
      ]
    end

    def update
      @loan_product = LoanProduct.find(params[:loan_product_id])
      @loan_product_type = LoanProductTagging.find(params[:id])

      if @loan_product_type.update(loan_product_type_params)
        redirect_to administration_loan_product_path(@loan_product)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_loan_products_path,
            text: "Loan Products"
          },
          {
            is_link: true,
            path: administration_loan_product_path(@loan_product),
            text: @loan_product.to_s
          },
          {
            text: "Edit #{@loan_product_type}"
          }
        ]

        render :edit
      end
    end

    def destroy
      @loan_product = LoanProduct.find(params[:loan_product_id])
      @loan_product_type = LoanProductTagging.find(params[:id])

      @loan_product_type.destroy!

      redirect_to administration_loan_product_path(@loan_product)
    end

    private

    def loan_product_type_params
      params.require(:loan_product_tagging).permit!
    end
  end
end
