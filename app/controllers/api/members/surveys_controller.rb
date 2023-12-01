module Api
    module Members
      class SurveysController < ::Api::V3::ApplicationController
        before_action :authenticate_member!
        before_action :authorize_active_member!

        def index
            cmd = ::Members::GetSurveys.new(
                member: @current_member
            )

            cmd.execute!
    
            render json: cmd.payload
        end

        def create_survey_mobile
          member  = Member.find(params[:id])
          survey  = Survey.find_by_id(params[:survey_id])
  
          config = {
            member: member,
            survey: survey,
          }
    
          survey_answer = ::Members::BuildSurveyAnswerMobile.new(
              config: config
            ).execute!
    
          survey_answer.save!
  
          render json: { id: survey_answer.id }
        end

        def fetch_survey_answer
          survey_answer = SurveyAnswer.find(params[:survey_answer_id])

          render json: survey_answer
        end

        def update_survey_answer
          survey_answer = SurveyAnswer.find(params[:survey_answer_id])
          data = params[:data]
          survey_answer.update(data:data)
        end

      end
    end
end