module Api
  class MessagesController < ::Api::FrontController
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
        if @user.present? and member_id.present?
          @member = ReadOnlyMember.find(member_id)
        end

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
