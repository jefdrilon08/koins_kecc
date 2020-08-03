module Api
  module V1
    class UsersController < ApiController
      before_action :authenticate_user!, except: [:login]

      def change_password
        password              = params[:password]
        password_confirmation = params[:password_confirmation]

        validator = ::Users::ValidateChangePassword.new(
                      password: password,
                      password_confirmation: password_confirmation,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].any?
          render json: validator.errors, status: 400
        else
          ::Users::ChangePassword.new(
            password: password,
            password_confirmation: password_confirmation,
            user: current_user
          ).execute!

          render json: { message: "ok" }
        end
      end

      def login
        username  = params[:username]
        password  = params[:password]

        user  = User.where("lower(username) = ?", username).first

        if user && user.valid_password?(password)
          sign_in(:user, user)
          
          render json: { message: "ok" }
        else
          errors  = {
            full_messages: [
              "user not found"
            ]
          }

          render json: { errors: errors }, status: 400
        end
      end

      def roles
        render json: { roles: current_user.roles, username: current_user.username } 
      end
    end
  end
end
