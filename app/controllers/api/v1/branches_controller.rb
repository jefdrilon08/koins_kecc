module Api
  module V1
    class BranchesController < ApiController
      before_action :authenticate_user!

      def index
        branches  = Branch.all.order("name ASC")

        data  = []

        branches.each do |o|
          data << {
            id: o.id,
            name: o.name
          }
        end

        render json: { branches: data }
      end
    end
  end
end
