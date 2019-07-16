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

        # Fetch repayment rates
        rr_data = DataStore.repayment_rates.where(
                    "meta->>'branch_id' = ? AND status = ?",
                    branch.id,
                    "done"
                  ).order(
                    "(meta->>'as_of')::date ASC"
                  ).last

        # Fetch branch loan stats
#        branch_loans_stats        = DataStore.branch_loans_stats.where(
#                                      "meta->>'branch_id' = ? AND status = ?", 
#                                      branch.id,
#                                      "done"
#                                    ).order(
#                                      "(meta->>'as_of')::date ASC"
#                                    ).last

        if rr_data.present?
          branch_loans_stats  = ::DataStores::BuildBranchLoanStatsFromRr.new(
                                  rr_data: rr_data.data.with_indifferent_access
                                ).execute!
        end

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

        # Fetch watchlist
        if rr_data.present?
          watchlist = ::DataStores::BuildWatchlistFromRr.new(
                        rr_data: rr_data.data.with_indifferent_access
                      ).execute!
        end

        data[:watchlist]  = watchlist || false

        # Fetch center meeting days
        data[:centers]  = ::Branches::FetchCenters.new(
                            config: {
                              branch: branch
                            }
                          ).execute!

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
