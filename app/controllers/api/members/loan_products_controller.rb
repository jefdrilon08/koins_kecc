module Api
  module Members
    class LoanProductsController < ::Api::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        # loan_products = LoanProduct.all.map{ |o|
        #   o.to_h
        # }

        # get all active loans of member
        active_loans = Loan.active.where(member_id: @current_member.id).select(:id, :loan_product_id) 

        # check if its below 5 weeks to pay
        active_loans = active_loans.map{ |item,index|
          # get the total number of unpaid weeks
          not_paid_count = AmortizationScheduleEntry.where(loan_id: item.id).where('is_paid is NULL or is_paid = ?', false).count

          # get all the grather than 5 weeks
          if not_paid_count > 5
            {
              id: item.id,
              loan_product_id: item.loan_product_id
            }
          end
        }
        # removes all nil values
        active_loans.compact!
        
        # get all loan products
        # loan_products = LoanProduct.select("*")
        loan_products = LoanProduct.where(is_active: true).all
        
        # remove the 6 weeks and above the loan products from member
        loan_products = loan_products.where.not(id: active_loans.pluck(:loan_product_id)).order(:name).map{ |o|
          o.to_h
        }
        
        render json: { loan_products: loan_products }
      end
    end
  end
end
