module Members
  class ValidateSaveSurveyAnswer < AppValidator
    def initialize(config:)
      super()

      @config         = config
      @data           = @config[:data]
      @survey_answer  = @config[:survey_answer]
      @user           = @config[:user]
    end

    def execute!
      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
