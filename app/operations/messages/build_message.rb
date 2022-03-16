module Messages
  class BuildMessage
    attr_accessor :message,
                  :member,
                  :data

    def initialize(message:)
      @message  = message
      @member   = @message.member

      @data = {
        id: @message.id,
        topic: @message.topic,
        content: @message.content,
        updated_at: @message.updated_at,
        member_id: @member.id,
        first_name: @member.first_name,
        middle_name: @member.middle_name,
        last_name: @member.last_name,
        user_id: @member.user_id,
        identification_number: @member.identification_number
      }
    end

    def execute!
      @data
    end
  end
end
