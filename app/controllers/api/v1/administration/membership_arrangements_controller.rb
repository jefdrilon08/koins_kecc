module Api
  module V1
    module Administration
      class MembershipArrangementsController < ApplicationController
        before_action :authenticate_user!

        def update_data
          membership_arrangement  = MembershipArrangement.find_by_id(params[:id])
          data                    = JSON.parse(params[:data])
          user                    = current_user

          errors  = ::Administration::MembershipArrangements::ValidateUpdateData.new(
                      membership_arrangement: membership_arrangement,
                      data: data,
                      user: user
                    ).execute!

          if errors[:full_messages].any?
            render json: { errors: errors[:full_messages] }, status: 402
          else
            membership_arrangement.update!(
              data: data
            )

            render json: { message: "ok" }
          end
        end
      end
    end
  end
end
