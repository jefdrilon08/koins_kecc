module Members
  class ValidateDelete  < AppValidator
    def initialize(config:)
      super()

      @config = config
      @member = @config[:member]
      @user   = @config[:user]
    end

    def execute!
      if !@member.pending?
        @errors[:messages] << {
          key: "status",
          message: "member not pending"
        }
      end

      #not_yet_implemented!
      
      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
