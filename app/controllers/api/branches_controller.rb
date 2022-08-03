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

    def close
      branch_id     = params[:branch_id]
      branch        = ReadOnlyBranch.find_by_id(branch_id)
      closing_date  = params[:closing_date]

      cmd = ::Branches::ValidateClose.new(
        branch: branch,
        closing_date: closing_date
      )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        render json: { message: "ok" }
      end
    end
  end
end
