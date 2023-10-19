module Api
  class ClientMetaController < ::Api::V3::ApplicationController
    before_action :authenticate_member!
    before_action :authorize_active_member!

    def loan_products
      render json: { }
    end
  end
end
