module Administration
  class SurveysController < ApplicationController
    before_action :authenticate_user!

    def index
      @surveys  = Survey.select("*").order("name ASC")
    end

    def show
      @survey = Survey.find(params[:id])
    end
  end
end
