module Api
  module V1
    class CentersController < ApiController
      before_action :authenticate_user!
      before_action :authenticate_app_request!, only: [:fetch_centers]

      def fetch_centers
        if params[:branch_id].blank?
          render json: { message: "branch_id required" }, status: 400
        else
          centers = Center.where(branch_id: params[:branch_id])

          render json: { centers: centers }
        end
      end

      def assign_officer
        officer = User.where(id: params[:officer_id]).first
        center  = Center.where(id: params[:id]).first

        config = {
          user: current_user,
          officer: officer,
          center: center
        }

        errors  = ::Centers::ValidateAssignOfficer.new(
                    config: config
                  ).execute! 

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Centers::AssignOfficer.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def index
        branches  = Branch.where(
                      id: UserBranch.active.where(
                        user_id: current_user.id
                      ).pluck(:branch_id)
                    ).order("name ASC")

        centers = Center.where("branch_id IN (?)", branches.id)

        data  = []

        centers.find_each(batch_size: 1000) do |o|
          members = []

          o.members.order("last_name ASC").each do |m|
            members << {
              id: m.id,
              name: m.full_name
            }
          end

          data << {
            id: o.id,
            name: o.name,
            members: members
          }
        end

        render json: { centers: data }
      end

      def centers
        centers = Center.where("branch_id IN (?)", @branches.pluck(:id))

        data  = []

        centers.find_each(batch_size: 1000) do |o|
          members = []

          o.members.order("last_name ASC").each do |m|
            members << {
              id: m.id,
              name: m.full_name
            }
          end

          data << {
            id: o.id,
            name: o.name,
            members: members
          }
        end

        render json: { centers: data }
      end
    end
  end
end
