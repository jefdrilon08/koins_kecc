module Api
  module V1
    class OnlineApplicationsController < ApplicationController
      before_action :authenticate_user!

      def assign_branch
        online_application  = OnlineApplication.find(params[:id])

        validator = ::OnlineApplications::ValidateAssignBranch.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          branch = ReadOnlyBranch.find(params[:branch_id])

          online_application.update!(
            branch: branch
          )

          render json: { message: "ok" }
        end
      end

      def verify
        online_application  = OnlineApplication.find(params[:id])

        membership_type         = MembershipType.find_by_id(params[:membership_type_id])
        membership_arrangement  = MembershipArrangement.find_by_id(params[:membership_arrangement_id])
        center                  = Center.find_by_id(params[:center_id])

        validator = ::OnlineApplications::ValidateVerify.new(
                      online_application: online_application,
                      user: current_user,
                      membership_type: membership_type,
                      membership_arrangement: membership_arrangement,
                      center: center
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          branch = nil

          if params[:branch_id].present?
            branch = ReadOnlyBranch.find_by_id(params[:branch_id])
          end

          cmd = ::OnlineApplications::Verify.new(
                  online_application: online_application,
                  user: current_user,
                  branch: branch,
                  center: center,
                  membership_type: membership_type,
                  membership_arrangement: membership_arrangement
                )

          cmd.execute!

          render json: { message: "ok" }
        end
      end

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
                  user: current_user,
                  reason: reason
                )

          cmd.execute!

          render json: { message: "ok" }
        end
      end

      def process_application
        online_application  = OnlineApplication.find(params[:id])

        validator = ::OnlineApplications::ValidateProcess.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { errors: validator.errors[:full_messages] }, status: 403
        else
          online_application.update!(status: "processing")

          ProcessOnlineApplication.perform_later({
            id: online_application.id,
            user_id: current_user.id
          })

          render json: { message: "ok" }
        end
      end
    end
  end
end
