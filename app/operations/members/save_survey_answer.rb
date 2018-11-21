module Members
  class SaveSurveyAnswer < AppValidator
    def initialize(config:)
      @config         = config
      @data           = @config[:data]
      @survey_answer  = @config[:survey_answer]
      @user           = @config[:user]
    end

    def execute!
      @survey_answer.update!(
        data: @data[:data]
      )

      @survey_answer
    end
  end
end
