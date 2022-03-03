module Api
  class UsersController < ActionController::API
    def login
      username  = params[:username]
      password  = params[:password]

      cmd = ::Users::ValidateLogin.new(
              username: username,
              password: password
            )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        render json: { token: cmd.token, user: cmd.user.user_object }
      end
    end
  end
end
