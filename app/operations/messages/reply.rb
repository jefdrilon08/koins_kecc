module Messages
  class Reply
    attr_accessor :message,
                  :reply,
                  :reply_message

    def initialize(message:, reply:, user:, member:)
      @message  = message
      @reply    = reply
      @user     = user
      @member   = member
    end

    def execute!
    end
  end
end
