module Api
  class FrontController < ActionController::API
    def authenticate_member!
      token = request.headers["X-KOINS-PWA-TOKEN"]

      if token.blank?
       
        render json: { errors: { user: 'token required' } }, status: :unprocessable_entity
      else
        begin
          decoded = JWT.decode(token, Rails.application.secret_key_base)
          id      = decoded.first["id"]

          @member = ReadOnlyMember.find_by_id(id)

          if @member.blank?
            render json: { errors: { user: 'user not found' } }, status: :unprocessable_entity
          end
        rescue Exception => e
          logger.info("Exception occured")
          logger.info(e)
          render json: { errors: { user: 'invalid token', e: e } }, status: :unprocessable_entity
        end
      end
    end
  end
end
