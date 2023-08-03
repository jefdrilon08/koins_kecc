module Api
  module V3
    class UserBranchesController < ::Api::V3::ApplicationController
      before_action :authenticate_user!
      before_action :authorize_mis!
      before_action :load_resource!, only: [:toggle]

      def load_resource!
        if params[:id].blank?
          render json: { id: ['required'] }, status: :unprocessable_entity
        else
          @user_branch = UserBranch.find_by_id(params[:id])

          if @user_branch.blank?
            render json: { message: 'not found' }, status: :not_found
          end
        end
      end

      def index
        user = User.find_by_id(params[:id]) 

        if user.blank?
          render json: { message: 'not found' }, status: :not_found
        else
          user_branches = UserBranch.where(
            user_id: user.id
          ).map{ |o| o.to_h }

          render json: user_branches
        end
      end

      def toggle
        cmd = ::Core::UserBranches::Toggle.new(
          user_branch: @user_branch
        )

        cmd.execute!

        render json: { active: cmd.user_branch.active ? true : nil }
      end
    end
  end
end
