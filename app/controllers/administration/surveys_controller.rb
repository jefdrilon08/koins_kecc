module Administration
  class SurveysController < ApplicationController
    before_action :authenticate_user!

    def index
      @surveys  = Survey.select("*").order("name ASC")

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Surveys"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New Survey"
        }
      ]
    end

    def show
      @survey = Survey.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_surveys_path,
          text: "Surveys"
        },
        {
          text: "#{@survey}"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-delete",
          link: "#",
          class: "fa fa-times",
          text: "Delete"
        }
      ]
    end

    def edit
      @survey = Survey.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_surveys_path,
          text: "Surveys"
        },
        {
          text: "Edit #{@survey.id}"
        }
      ]
    end

    def update
      @survey = Survey.find(params[:id])

      if @survey.update(survey_params)
        redirect_to administration_survey_path(@survey)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_surveys_path,
            text: "Surveys"
          },
          {
            text: "Edit #{@survey.id}"
          }
        ]

        render :edit
      end
    end

    def survey_question_form
      @survey = Survey.find(params[:survey_id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_surveys_path,
          text: "Surveys"
        },
        {
          is_link: true,
          path: administration_survey_path(@survey),
          text: @survey
        },
        {
          text: "Question Form"
        }
      ]

      @payload = {
        id: params[:survey_question_id],
        surveyId: @survey.id
      }
    end

    private

    def survey_params
      params.require(:survey).permit(:name)
    end
  end
end
