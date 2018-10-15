module Api
  module V1
    class AccountingCodesController < ApiController
      before_action :authenticate_user!

      def index
        accounting_codes  = AccountingCode.all

        data  = accounting_codes.map{ |o|
                  {
                    id: o.id,
                    name: o.name
                  }
                }

        render json: { accounting_codes: data }
      end
    end
  end
end
