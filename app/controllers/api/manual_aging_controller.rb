module Api
  class ManualAgingController < ::Api::V3::ApplicationController
    before_action :authenticate_user!
    before_action :load_resource!, only: [:show]
    before_action :authorize_owner!

    def authorize_owner!
      branch_id = @manual_aging.meta["branch_id"]

      if @current_user.user_branches.where(branch_id: branch_id).count == 0
        render json: { message: 'unauthorized' }, status: :unauthorized
      end
    end

    def load_resource!
      @manual_aging = DataStore.manual_aging.find_by_id(params[:id])

      if @manual_aging.blank?
        render json: { message: 'not found' }, status: :not_found
      end
    end

    def show
      render json: @manual_aging
    end
  end
end
