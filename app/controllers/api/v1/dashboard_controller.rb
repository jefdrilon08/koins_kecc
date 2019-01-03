module Api
  module V1
    class DashboardController < ApiController
      before_action :authenticate_user!

      def index
        branches  = build_branches
        branch    = nil

        if params[:branch_id].present?
          branch  = Branch.find(params[:branch_id])
        elsif branches.size > 0
          branch  = Branch.find(branches.first[:id])
        end

        data  = {
          branches: build_branches
        }

        if current_user.roles.include?("OAS")
          # Fetch branch loan stats
          branch_loans_stats        = DataStore.branch_loans_stats.where(
                                        "meta->>'branch_id' = ? AND status = ?", 
                                        branch.id,
                                        "done"
                                      ).order(
                                        "(meta->>'as_of')::date ASC"
                                      ).last

          data[:branch_loans_stats] = branch_loans_stats || false

          # Fetch member counts
          member_counts = DataStore.member_counts.where(
                            "meta->>'branch_id' = ? AND status = ?", 
                            branch.id,
                            "done"
                          ).order(
                            "(meta->>'as_of')::date ASC"
                          ).last

          data[:member_counts]  = member_counts
        end

        render json: data
      end

      private

      def build_branches
        branches  = Branch.where(
                      id: UserBranch.active.where(
                        user_id: current_user.id
                      ).pluck(:branch_id)
                    ).order("name ASC")

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

        data
      end
    end
  end
end
