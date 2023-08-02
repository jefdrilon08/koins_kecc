module Api
  module V3
    class UserBranchesController < ::Api::V3::ApplicationController
      before_action :authenticate_user!
      before_action :authorize_mis!

      def toggle
        validator = ::Core::UserBranches::ValidateToggle.new(
          branch_id:  params[:branch_id],
          user_id:    params[:user_id] 
        )

        validator.execute!

        if validator.valid?
          cmd = ::Core::UserBranches::Toggle.new(
            branch_id:  params[:branch_id],
            user_id:    params[:user_id]
          )

          cmd.execute!

          if cmd.user_branch.active
            render json: { active: true }
          else
            render json: { active: nil }
          end
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end
    end
  end
end
