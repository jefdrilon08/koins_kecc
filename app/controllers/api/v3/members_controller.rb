module Api
  module V3
    class MembersController < ::Api::V3::ApplicationController
      before_action :authenticate_user!
      before_action :authorize_mis!

      def import_members
        validator = ::Core::Members::ValidateImportMembers.new(
          data: params[:data]
        )

        validator.execute!

        if validator.valid?
          render json: { message: 'ok' }
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end
    end
  end
end
