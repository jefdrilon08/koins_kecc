module Api
  class MessagesController < ::Api::FrontController
    before_action :authenticate_user_or_member!

    def index
      if @member.present?
      elsif @user.present?
        messages  = Message.joins(:member).select(
                      "messages.id AS id, messages.topic, messages.status, members.first_name, members.last_name, members.middle_name, messages.updated_at"
                    ).order("updated_at DESC")

        messages  = messages.map{ |o|
                      {
                        id: o.id,
                        topic: o.topic,
                        first_name: o.first_name,
                        middle_name: o.middle_name,
                        last_name: o.last_name,
                        status: o.status,
                        updated_at: o.updated_at.strftime("%b %d, %Y %H:%m")
                      }
                    }

        render json: { messages: messages }
      else
        render json: { message: "Invalid" }, status: :unprocessable_entity
      end
    end

    def reply
      message = Message.find_by_id(params[:id])
      reply   = params[:reply]

      validator = ::Messages::ValidateReply.new(
                    message: message,
                    reply: reply
                  )

      validator.execute!

      if validator.errors.any?
        render json: { errors: validator.errors }, status: :unprocessable_entity
      else
        cmd = ::Messages::Reply.new(
                message: message,
                reply: reply,
                user: @user,
                member: @member
              )

        cmd.execute!

        reply_message = cmd.reply_message

        render json: { message: repply_message }
      end
    end

    def show
      message = Message.find_by_id(params[:id])

      cmd = ::Messages::BuildMessage.new(
              message: message
            )

      cmd.execute!

      render json: { message: cmd.data }
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
