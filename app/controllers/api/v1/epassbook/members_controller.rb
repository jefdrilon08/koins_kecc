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
            data  = {
              id: member.id,
              first_name: member.first_name,
              middle_name: member.middle_name,
              last_name: member.last_name,
              full_name: member.full_name,
              branch: member.branch.to_s,
              center: member.center.to_s
            }

            render json: data
          end
        end
      end
    end
  end
end
