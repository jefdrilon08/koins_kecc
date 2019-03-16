module Api
  module V1
    class AccountingFundsController < ApiController
      before_action :authenticate_user!

      def index
        accounting_funds  = AccountingFund.all.order("name ASC")

        data  = accounting_funds.map{ |f|
                  {
                    id: f.id,
                    name: f.name
                  }
                }

        render json: { accounting_funds: data }
      end
    end
  end
end
