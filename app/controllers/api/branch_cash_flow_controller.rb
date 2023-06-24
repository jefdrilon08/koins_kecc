module Api
  class BranchCashFlowController < ::Api::FrontController
    before_action :authenticate_user!

    def generate
      raise params.inspect

      render json: { records: records }
    end
  end
end
