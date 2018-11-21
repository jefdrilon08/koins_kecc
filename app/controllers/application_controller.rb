class ApplicationController < ActionController::Base
  before_action :load_defaults

  def load_defaults
    @current_date = Date.today

    if user_signed_in?
      # TODO: Only fetch user assigned branches
      @branches = Branch.where(id: UserBranch.active.where(user_id: current_user.id).pluck(:branch_id)).order("name ASC")
    end
  end
end
