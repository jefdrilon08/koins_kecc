module Administration
  class SurveysController < ApplicationController
    before_action :authenticate_user!

    def index
      @surveys  = Survey.select("*").order("name ASC")
    end

    def show
      @survey = Survey.find(params[:id])
    end

    def edit
      @survey = Survey.find(params[:id])
    end

    def update
      @survey = Survey.find(params[:id])

      if @survey.update(survey_params)
        redirect_to administration_survey_path(@survey)
      else
        render :edit
      end
    end

    def survey_question_form
      @survey = Survey.find(params[:survey_id])
    end

    private

    def survey_params
      params.require(:survey).permit(:name)
    end
  end
end
