module Api
  module V1
    module Epassbook
      class MembersController < ApiEpassbookController
        before_action :authenticate_member_access_token!

        def show
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            render json: member
          end
        end
      end
    end
  end
end
