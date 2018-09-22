module Administration
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
    end
  end
end
