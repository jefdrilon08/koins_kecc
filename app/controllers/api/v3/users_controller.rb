module Api
  module V3
    class UsersController < ::Api::V3::ApplicationController
      before_action :authenticate_user!
      before_action :authorize_mis!
      before_action :load_resource!, only: [:update, :show]

      def load_resource!
        @user = User.find_by_id(params[:id])

        if @user.blank?
          render json: { message: 'not found' }, status: :not_found
        end
      end

      def show
        render json: @user.to_h
      end

      def update
        validator = ::Core::Users::ValidateUpdate.new(
          user:                   @user,
          email:                  params[:email],
          username:               params[:username],
          identification_number:  params[:identification_number],
          roles:                  params[:roles],
          password:               params[:password],
          password_confirmation:  params[:password_confirmation],
          profile_picture:        params[:profile_picture]
        )

        validator.execute!

        if validator.valid?
          cmd = ::Core::Users::Update.new(
            user:                   @user,
            email:                  params[:email],
            username:               params[:username],
            identification_number:  params[:identification_number],
            first_name:             params[:first_name],
            last_name:              params[:last_name],
            roles:                  params[:roles],
            password:               params[:password],
            password_confirmation:  params[:password_confirmation],
            profile_picture:        params[:profile_picture],
            is_regular:             params[:is_regular],
            incentivized_date:      params[:incentivized_date]
          )

          cmd.execute!

          render json: { id: cmd.user.id }
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end

      def create
        validator = ::Core::Users::ValidateCreate.new(
          email:                  params[:email],
          username:               params[:username],
          identification_number:  params[:identification_number],
          first_name:             params[:first_name],
          last_name:              params[:last_name],
          roles:                  params[:roles],
          password:               params[:password],
          password_confirmation:  params[:password_confirmation],
          profile_picture:        params[:profile_picture]
        )

        validator.execute!

        if validator.valid?
          cmd = ::Core::Users::Create.new(
            email:                  params[:email],
            username:               params[:username],
            identification_number:  params[:identification_number],
            first_name:             params[:first_name],
            last_name:              params[:last_name],
            roles:                  params[:roles],
            password:               params[:password],
            password_confirmation:  params[:password_confirmation],
            profile_picture:        params[:profile_picture],
            is_regular:             params[:is_regular],
            incentivized_date:      params[:incentivized_date]
          )

          cmd.execute!

          render json: { id: cmd.user.id }
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end
    end
  end
end
