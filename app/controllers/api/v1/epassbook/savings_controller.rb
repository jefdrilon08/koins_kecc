module Api
  module V1
    module Epassbook
      class SavingsController < ApiEpassbookController
        before_action :authenticate_member_access_token!

        def index
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            data  = ::Epassbook::FetchMemberSavings.new(
                      member: member
                    ).execute!

            render json: data
          end
        end
      end
    end
  end
end
