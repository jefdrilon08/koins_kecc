module Api
  module V1
    class OnlineApplicationsController < ApplicationController
      before_action :authenticate_user!

      def reject
        online_application  = OnlineApplication.find(params[:id])
        reason              = params[:reason]

        validator = ::OnlineApplications::ValidateReject.new(
                      online_application: online_application,
                      user: current_user,
                      reason: reason
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          cmd = ::OnlineApplications::Reject.new(
                  online_application: online_application,
                  user: current_user
                )

          cmd.execute!

          render json: { message: "ok" }
        end
      end

      def process_application
        online_application  = OnlineApplication.find(params[:id])
        branch              = ReadOnlyBranch.find_by_id(params[:branch_id])
        center              = ReadOnlyCenter.find_by_id(params[:center_id])

        validator = ::OnlineApplications::ValidateProcess.new(
                      online_application: online_application,
                      branch: branch,
                      center: center,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { errors: validator.errors[:full_messages] }, status: 403
        else
          cmd = ::OnlineApplications::Process.new(
                  online_application: online_application,
                  branch: branch,
                  center: center,
                  user: current_user
                )

          cmd.execute!

          render json: { message: "ok", member_id: cmd.member.id }
        end
      end
    end
  end
end
