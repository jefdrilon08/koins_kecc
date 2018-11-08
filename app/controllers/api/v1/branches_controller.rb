module Api
  module V1
    class BranchesController < ApiController
      before_action :authenticate_user!

      def index
        branches = Branch.where(id: UserBranch.active.where(user_id: current_user.id).pluck(:branch_id)).order("name ASC")

        data  = []

        branches.each do |o|
          centers = []

          o.centers.order("name ASC").each do |c|
            centers << {
              id: c.id,
              name: c.name
            }
          end

          data << {
            id: o.id,
            name: o.name,
            centers: centers
          }
        end

        render json: { branches: data }
      end
    end
  end
end
