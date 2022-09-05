module Api
  module Administration
    class BranchesController < ::Api::FrontController
      before_action :authorize_admin!

      def show
        branch = ReadOnlyBranch.find(params[:id])

        cmd = ::Branches::BuildBranchHash.new(
          branch: branch
        )

        cmd.execute!

        render json: cmd.data
      end
    end
  end
end
