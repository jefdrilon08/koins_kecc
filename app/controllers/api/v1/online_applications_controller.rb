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

        validator = ::OnlineApplications::ValidateVerify.new(
                      online_application: online_application,
                      user: current_user,
                      membership_type: membership_type,
                      membership_arrangement: membership_arrangement
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
