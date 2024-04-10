module Api
  class RepaymentRatesController < ::Api::V3::ApplicationController
    before_action :authenticate_user!
    before_action :load_resource!, only: [:show]
    before_action :authorize_owner!

    def authorize_owner!
      branch_id = @repayment_rate.meta["branch_id"]

      if @current_user.user_branches.where(branch_id: branch_id).count == 0
        render json: { message: 'unauthorized' }, status: :unauthorized
      end
    end

    def load_resource!
      @repayment_rate = DataStore.repayment_rates.find_by_id(params[:id])

      if @repayment_rate.blank?
        render json: { message: 'not found' }, status: :not_found
      end
    end

    def show
      render json: @repayment_rate
    end
  end
end
