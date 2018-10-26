class ApplicationController < ActionController::Base
  before_action :load_defaults

  def load_defaults
    @current_date = Date.today

    if user_signed_in?
      # TODO: Only fetch user assigned branches
      @branches = Branch.all
    end
  end
end
