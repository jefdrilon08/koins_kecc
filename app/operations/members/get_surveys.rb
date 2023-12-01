module Members
    class GetSurveys
      attr_accessor  :payload
  
      def initialize(member:)
        @member   = member
        @survey_answers = SurveyAnswer.where(
          "meta -> 'member' ->> 'id' = ?",
          @member.id
        ).order("updated_at DESC")
  
        @payload = {
          survey_answers: [],
          date_of_membership: ""
        }
      end
  
      def execute!  
        # @survey_answers.each do |surveys, indexSurvey|

        #   survey = SurveyAnswer.find(surveys.id)

        #   survey.data["answers"].each do |answers, indexAnswers|
        #     # puts "answersssssss: " + answers["score"].length.inspect
        #     if answers["answer"].length == 0
        #       survey.destroy!
        #       break 
        #     end
        #   end
        # end

        # @survey_answers = SurveyAnswer.where(
        #   "meta -> 'member' ->> 'id' = ?",
        #   @member.id
        # ).order("updated_at DESC")

        # Surveys
        

        @payload[:survey_answers] = @survey_answers.map{ |o|
          isComplete = true
          o.data["answers"].each do |answers, indexAnswers|
            # puts "answersssssss: " + answers["score"].length.inspect
            if answers["answer"].length == 0
              isComplete = false
              break
            end
          end

          {
            id:           o.id,
            survey_name:  o.survey.name,
            updated_at:   o.updated_at.localtime.strftime("%b %d, %Y"),
            isComplete: isComplete
          }
        }

        @payload[:date_of_membership] = @member.date_of_membership
      end
    end
  end
  

