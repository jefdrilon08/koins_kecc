module Api
  class UsersController < ActionController::API
    def change_password
      verification_token  = params[:verification_token]
      password            = params[:password]
      password_confirm    = params[:password_confirm]
      user                = User.find_by_verification_token(verification_token)

      cmd = ::Users::ValidateChangePassword.new(
        password:               password,
        password_confirmation:  password_confirm,
        user:                   user
      )

      cmd.execute!

      if cmd.errors[:full_messages].size > 0
        render json: { errors: cmd.errors[:full_messages] }, status: :unprocessable_entity
      else
        user.update!(
          is_verified: true,
          verification_token: nil,
          password: password,
          password_confirmation: password_confirm
        )

        render json: { message: "ok" }
      end
    end

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
