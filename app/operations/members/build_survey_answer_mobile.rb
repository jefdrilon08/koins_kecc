module Members
    class BuildSurveyAnswerMobile
      def initialize(config:)
        @config   = config

        @survey   = @config[:survey]
        @member   = @config[:member]
  
        @survey_answer  = SurveyAnswer.new(
                            survey_id: @survey.id
                          )
      end
  
      def execute!
        # Build meta
        meta  = {
          answered_by: {
            first_name: @member.first_name,
            last_name: @member.last_name
          },
          member: {
            id: @member.id,
            first_name: @member.first_name,
            last_name: @member.last_name
          },
          branch: {
            id: @member.branch.id,
            name: @member.branch.name
          },
          center: {
            id: @member.center.id,
            name: @member.center.name
          },
          survey: {
            id: @survey.id,
            name: @survey.name
          }
        }
  
        # Build data
        data  = {
          answers: []
        }
  
        @survey.survey_questions.order("priority ASC").each do |o|
          data[:answers] << {
            survey_question: o,
            answer: "",
            score: 0
          }
        end
  
        # Load
        @survey_answer.meta = meta
        @survey_answer.data = data
  
        @survey_answer
      end
    end
  end
  