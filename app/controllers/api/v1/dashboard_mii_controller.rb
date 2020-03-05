module Api
  module V1
    class DashboardMiiController < ApiController
      before_action :authenticate_user!

      def overview
        config  = {
          user: current_user,
          as_of: params[:as_of] || Date.today
        }

        data  = ::Dashboard::BuildOverview.new(
                  config: config
                ).execute!

        render json: data
      end

      def index
        branches  = build_branches
        branch    = nil

        if params[:branch_id].present?
          branch  = Branch.find(params[:branch_id])
        elsif branches.any?
          branch  = Branch.find(branches.first[:id])
        end

        data  = {
          branches: build_branches
        }

        # Fetch repayment rates
        rr_data = DataStore.repayment_rates.where(
                    "meta->>'branch_id' = ? AND status = ?",
                    branch.id,
                    "done"
                  ).order(
                    "(meta->>'as_of')::date ASC"
                  ).last

        # Fetch member counts
        member_counts = DataStore.member_counts.where(
                          "meta->>'branch_id' = ? AND status = ?", 
                          branch.id,
                          "done"
                        ).order(
                          "(meta->>'as_of')::date ASC"
                        ).last

        data[:member_counts]  = member_counts

        render json: data
      end

      private

      def build_branches
        data  = []

        @branches.each do |o|
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
