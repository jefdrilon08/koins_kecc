module Api
  module V1
    class BranchesController < ApiController
      before_action :authenticate_user!

      def index
        if params[:b].present?
          branches = current_user
            .branches
            .where(user_branches: { active: true })
            .map do |b|
              {
                id:      b.id,
                name:    b.name
              }
            end

          render json: { branches: branches }
        else
          branches = current_user
            .branches
            .includes(:centers)
            .where(user_branches: { active: true })
            .map do |b|
              {
                id:      b.id,
                name:    b.name,
                centers: b.centers.map { |c| { id: c.id, name: c.name } },
              }
            end

          render json: { branches: branches }
        end
      end

      def fetch_centers
        #branch  = @branches.where(id: params[:id]).first
        branch = @branches.select{ |o| o[:id] == params[:id] }.first

        centers = Center.where(branch_id: branch[:id]).order("name ASC").map{ |c| { id: c.id, name:  c.name } }

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
    end
  end
end
