module Api
  module V1
    module Epassbook
      class MembersController < ApiEpassbookController
        before_action :authenticate_member_access_token!

        def status
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            render json: { status: member.status }
          end
        end

        def show
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            branch  = member.branch
            center  = member.center

            data  = {
              id: member.id,
              first_name: member.first_name,
              middle_name: member.middle_name,
              status: member.status,
              last_name: member.last_name,
              full_name: member.full_name,
              branch: branch.to_s,
              branch_id: branch.id,
              center: center.to_s,
              center_id: center.id
            }

            render json: data
          end
        end
      end
    end
  end
end
