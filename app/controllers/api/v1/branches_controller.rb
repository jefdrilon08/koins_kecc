module Api
  module V1
    class BranchesController < ApiController
      before_action :authenticate_user!

      def fetch_centers
        branch  = @branches.where(id: params[:id]).first
        
        centers = branch.centers.map{ |c| { id: c.id, name:  c.name } }

        render json: { centers: centers }
      end

      def stats
        branch  = Branch.where(id: @branches.pluck(:id)).where(id: params[:id]).first
        as_of   = params[:as_of].try(:to_date)

        if as_of.blank?
          as_of = Date.today
        end

        if branch.blank?
          render json: { errors: ["not found"] }, status: 400
        else
          data_store  = DataStore.where(
                          "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                          branch.id,
                          as_of
                        ).last

          if data_store.blank?
            config  = {
              branch: branch,
              as_of: as_of
            }

            data_store  = ::DataStores::SaveBranchLoansStats.new(
                            config: config
                          ).execute!
          end

          render json: data_store.data
        end
      end

      def index
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

        render json: { branches: data }
      end
    end
  end
end
