module Api
  class ClientMetaController < ::Api::V3::ApplicationController
    before_action :authenticate_member!
    before_action :authorize_active_member!

    def loan_products
      cmd = ::LoanProducts::BuildClientList.new

      cmd.execute!

      render json: cmd.data
    end
  end
end
