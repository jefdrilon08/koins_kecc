module Api
  module Members
    class CoMakersController < ::Api::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!

      def index
        co_makers = Member.where(
          center_id: @current_member.center_id
        ).where.not(
          id: @current_member.id
        ).map{ |o|
          o.to_h
        }

        render json: { co_makers: co_makers }
      end
    end
  end
end
