module Api
  module V1
    module Administration
      class SurveysController < ApplicationController
        before_action :authenticate_user!

        def save
          config  = {
            id: params[:id],
            name: params[:name],
            user: current_user
          }

          errors  = ::Administration::Surveys::ValidateSave.new(
                      config: config
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 402
          else
            survey  = ::Administration::Surveys::Save.new(
                        config: config
                      ).execute!

            render json: { id: survey.id }
          end
        end

        def fetch
          survey  = Survey.find(params[:id])

          render json: survey
        end
        
        def delete
          survey  = Survey.find(params[:id])

          config  = {
            survey: survey,
            user: current_user
          }

          errors  = ::Administration::Surveys::ValidateDelete.new(
                      config: config
                    ).execute!

          if errors[:full_messages].any?
            render json: errors, status: 402
          else
            survey.destroy!

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
