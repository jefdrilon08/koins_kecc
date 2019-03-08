module Api
  module V1
    class CentersController < ApiController
      before_action :authenticate_user!

      def index
        branches  = Branch.where(
                      id: UserBranch.active.where(
                        user_id: current_user.id
                      ).pluck(:branch_id)
                    ).order("name ASC")

        centers = Center.where("branch_id IN (?)", branches.ids)

        data  = []

        centers.each do |o|
          members = []

          o.members.order("last_name ASC").each do |m|
            members << {
              id: m.id,
              name: m.full_name
            }
          end

          data << {
            id: o.id,
            name: o.name,
            members: members
          }
        end

        render json: { centers: data }
      end
    end
  end
end
