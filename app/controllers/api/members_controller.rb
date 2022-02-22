module Api
  class MembersController < ActionController::API
    def login
      username  = params[:username]
      password  = params[:password]

      cmd = ::Members::ValidateLogin.new(
              username: username,
              password: password
            )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        render json: { token: cmd.token, member: cmd.member.user_object }
      end
    end
  end
end
