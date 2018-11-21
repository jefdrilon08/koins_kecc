module Members
  class ValidateDeleteSurveyAnswer < AppValidator
    def initialize(config:)
      super()

      @config         = config
      @survey_answer  = @config[:survey_answer]
      @user           = @config[:user]
    end

    def execute!  
      if @survey_answer.blank?
        @errors[:messages] << {
          key: "survey_anwser",
          message: "survey not found"
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
