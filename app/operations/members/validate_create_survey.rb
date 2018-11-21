module Members
  class ValidateCreateSurvey < AppValidator
    def initialize(config:)
      super()

      @config = config
      @survey = @config[:survey]
      @member = @config[:member]
      @user   = @config[:user]
    end

    def execute!  
      if @survey.blank?
        @errors[:messages] << {
          key: "survey",
          message: "survey not found"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
