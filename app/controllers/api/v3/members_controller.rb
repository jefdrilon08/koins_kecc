module Api
  module V3
    class MembersController < ::Api::V3::ApplicationController
      before_action :authenticate_user!, except: [:login, :dashboard, :savings]
      before_action :authorize_mis!, except: [:login, :dashboard, :savings]
      before_action :authenticate_member!, only: [:dashboard, :savings]
      before_action :authorize_active_member!, only: [:dashboard, :savings]

      def dashboard
        cmd = ::Members::GetDashboard.new(
          member: @current_member
        )

        cmd.execute!

        render json: cmd.payload
      end

      def login
        username  = params[:username]
        password  = params[:password]

        cmd = ::Members::ValidateLogin.new(
          username: username,
          password: password
        )

        cmd.execute!

        if cmd.invalid?
          render json: cmd.errors, status: :unprocessable_entity
        else
          render json: { token: cmd.token, member: cmd.member.user_object }
        end
      end

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
