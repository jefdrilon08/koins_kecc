module Api
  module V1
    class OnlineApplicationsController < ApiController
      #skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def assign_branch
        online_application  = OnlineApplication.find(params[:id])
        data_online_application = online_application.data.with_indifferent_access
    
        approve_process = { type: "assign_branch_by", name: current_user.full_name, date_assign: Date.today  }
        
        validator = ::OnlineApplications::ValidateAssignBranch.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { full_messages: validator.errors[:full_messages] }, status: 403
        else
          branch = ReadOnlyBranch.find(params[:branch_id])
          data_online_application["approve_process"] = []
          data_online_application["approve_process"] << approve_process
          online_application.update!(
            branch: branch,
            data: data_online_application
          )

          render json: { message: "ok" }
        end
      end

      def verify
        online_application  = OnlineApplication.find(params[:id])
        data_online_application = online_application.data.with_indifferent_access

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
          

          approve_process = {  type: "verify_by",  name: current_user.full_name, date_assign: Date.today  }
          if data_online_application["approve_process"].present?
            data_online_application["approve_process"] << approve_process
            online_application.update!(
              data: data_online_application
            )
          else
            data_online_application["approve_process"] = []
            data_online_application["approve_process"] << approve_process
            online_application.update!(
              data: data_online_application
            )
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
        data_online_application = online_application.data.with_indifferent_access

        validator = ::OnlineApplications::ValidateProcess.new(
                      online_application: online_application,
                      user: current_user
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { errors: validator.errors[:full_messages] }, status: 403
        else
          approve_process = {  type: "process_by",  name: current_user.full_name, date_assign: Date.today  }
          if data_online_application["approve_process"].present?
          
            data_online_application["approve_process"] << approve_process
            online_application.update!(status: "processing", data: data_online_application)
          else
            data_online_application["approve_process"] = []
            data_online_application["approve_process"] << approve_process
            online_application.update!(status: "processing", data: data_online_application)
          end

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
