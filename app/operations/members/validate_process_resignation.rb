module Members
  class ValidateProcessResignation < AppValidator
    def initialize(config:)
      super()

      @config = config

      @data = @config[:data]
      @user = @config[:user]
    end

    def execute!
      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      else
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
