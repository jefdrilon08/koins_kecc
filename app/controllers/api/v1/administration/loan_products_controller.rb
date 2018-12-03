module Api
  module V1
    module Administration
      class LoanProductsController < ApiController
        before_action :authenticate_user!

        def delete
          loan_product  = LoanProduct.where(id: params[:id]).first

          config  = {
            loan_product: loan_product,
            user: current_user
          }

          errors  = ::LoanProducts::ValidateDelete.new(
                      config: config
                    ).execute!

          if errors[:messages].size > 0
            render json: errors, status: 400
          else
            loan_product_name = loan_product.name

            loan_product.destroy!

            ActivityLog.create!(
              content: "#{current_user.full_name} deleted loan_product #{loan_product_name}",
              activity_type: "delete",
              data: {
                user_id: current_user.id,
                loan_product_name: loan_product_name
              }
            )

          end
        end
      end
    end
  end
end
