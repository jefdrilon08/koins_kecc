module Api
  class BranchesController < ::Api::FrontController
    before_action :authenticate_user!

    def index
      branches  = ReadOnlyBranch.select("id, name").where(
                    id: ReadOnlyUserBranch.where(
                          active: true,
                          user_id: @user.id
                        ).pluck(:branch_id)
                  ).order("name ASC")

      branches  = branches.map{ |o|
                    {
                      id: o.id,
                      name: o.name
                    }
                  }

      render json: { branches: branches }
    end
  end
end
