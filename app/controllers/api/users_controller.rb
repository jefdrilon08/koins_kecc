module Api
  class UsersController < ActionController::API
    def forgot_password
      email = params[:email]

      cmd = ::Users::ValidateForgotPassword.new(
        email: email
      )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        user = cmd.user

        ProcessForgotPassword.perform_later({
          email: user.email
        })

        render json: { message: "ok" }
      end
    end

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
        sign_in(:user, cmd.user)

        render json: { token: cmd.token, user: cmd.user.user_object }
      end
    end
  end
end
