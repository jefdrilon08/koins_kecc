module Api
  class MeessagesController < ::Api::FrontController
    before_action :authenticate_user_or_member!

    def index
    end

    def create
      topic   = params[:topic]
      content = params[:content]
    end
  end
end
