module Api
  module V2
    module Members
      class LoansController < ApiController
        before_action :authenticate_api_member!

        def index
          data  = ::Epassbook::FetchActiveLoans.new(
                    member: @member 
                  ).execute!

          render json: data
        end

        def show
          loan = Loan.find(params[:id])

          data  = ::Epassbook::FetchLoan.new(
                    member: @member,
                    loan: loan
                  ).execute!

          render json: data
        end
      end
    end
  end
end
