module Api
  module V1
    class UsersController < ApiController
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
    end
  end
end
