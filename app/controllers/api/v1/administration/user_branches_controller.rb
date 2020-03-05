module Api
  module V1
    module Administration
      class UserBranchesController < ApplicationController
        before_action :authenticate_user!

        def index
          user  = User.where(id: params[:id]).first

          config  = {
            user: user,
            current_user: current_user
          }

          user_branches = ::Administration::UserBranches::Fetch.new(
                            config: config
                          ).execute!

          render json: { user_branches: user_branches }
        end

        def toggle
          user_branch = UserBranch.where(id: params[:id]).first

          config  = {
            user: user_branch.user,
            user_branch: user_branch,
            current_user: current_user
          }

          errors  = ::Administration::UserBranches::ValidateToggle.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Administration::UserBranches::Toggle.new(
              config: config
            ).execute!

            user_branches = ::Administration::UserBranches::Fetch.new(
                              config: config
                            ).execute!

            render json: { user_branches: user_branches }
          end
        end
      end
    end
  end
end
