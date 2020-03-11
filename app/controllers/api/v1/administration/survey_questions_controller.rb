module Api
  module V1
    module Administration
      class SurveyQuestionsController < ApplicationController
        before_action :authenticate_user!

        def save
          config  = {
            id: params[:id],
            survey_id: params[:survey_id],
            data: JSON.parse(params[:data]).to_h.with_indifferent_access,
            user: current_user
          }

          errors  = ::Administration::SurveyQuestions::ValidateSave.new(
                      config: config
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 402
          else
            survey_question = ::Administration::SurveyQuestions::Save.new(
                                config: config
                              ).execute!

            render json: { id: survey_question.id }
          end
        end

        def fetch
          config  = {
            id: params[:id],
            survey_id: params[:survey_id]
          }

          survey  = ::Administration::SurveyQuestions::Fetch.new(
                      config: config
                    ).execute!

          render json: survey
        end
        
        def delete
          survey_question = SurveyQuestion.find(params[:id])

          config  = {
            survey_question: survey_question,
            user: current_user
          }

          errors  = ::Administration::SurveyQuestions::ValidateDelete.new(
                      config: config
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 402
          else
            survey_question.destroy!

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
