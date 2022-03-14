module Api
  class MeessagesController < ::Api::FrontController
    before_action :authenticate_user_or_member!

    def index
    end

    def create
      topic     = params[:topic]
      content   = params[:content]
      member_id = params[:member_id]

      validator = ::Messages::ValidateCreate.new(
                    topic: topic,
                    content: content
                  )

      validator.execute!

      if validator.errors.any?
        render json: { errors: validator.errors }, status: :unprocessable_entity
      else
        cmd = ::Messages::Create.new(
                topic: topic,
                content: content,
                member: @member,
                user: @user
              )

        cmd.execute!

        render json: { id: cmd.message.id }
      end
    end
  end
end
