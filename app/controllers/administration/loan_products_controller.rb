module Administration
  class LoanProductsController < ApplicationController
    before_action :authenticate_user!

    def download
      data      = ::LoanProducts::GenerateHashList.new.execute!
      filename  = "loan-products-#{Time.now.to_i}.json"
      path      = "#{Rails.root}/tmp"

      file  = ::Utils::WriteToJsonFile.new(
                config: {
                  filename: filename,
                  path: path,
                  data: data
                }
              ).execute!

      send_file file, filename: filename, type: "text/json"
    end

    def index
      @loan_products  = LoanProduct.select("*").order("priority ASC, name ASC")
    end

    def show
      @loan_product         = LoanProduct.find(params[:id])
      @prerequisite_id      = @loan_product.prerequisite.try(:id)
      @maintaining_balance  = @loan_product.maintaining_balance
    end

    def new
      @loan_product = LoanProduct.new
    end

    def create
      @loan_product = LoanProduct.new(loan_product_params)

      ActivityLog.create!(
        content: "#{current_user.full_name} created loan_product #{@loan_product}",
        activity_type: "create",
        data: {
          user_id: current_user.id,
          loan_product: @loan_product
        }
      )

      if @loan_product.save
        redirect_to administration_loan_product_path(@loan_product)
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

        ActivityLog.create!(
          content: "#{current_user.full_name} updated loan_product #{@loan_product}",
          activity_type: "modification",
          data: {
            user_id: current_user.id,
            loan_product: @loan_product
          }
        )

        redirect_to administration_loan_product_path(@loan_product)
      else
        render :edit
      end
    end

    private

    def loan_product_params
      params.require(:loan_product).permit!
    end
  end
end
