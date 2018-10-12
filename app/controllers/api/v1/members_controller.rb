module Api
  module V1
    class MembersController < ApiController
      def index
        members = Member.all.order("last_name ASC")

        data  = []

        members.each do |o|
          data << {
            id: o.id,
            name: o.full_name
          }
        end

        render json: { members: data }
      end

      def generate_access_token
        member  = Member.where(id: params[:id]).first

        if member.blank?
          render json: { errors: ["member not found"] }, status: 400
        else
          if member.update!(access_token: "#{SecureRandom.hex(32)}")
            render json: { message: "ok" }
          else
            render json: { errors: ["something went wrong"] }
          end
        end
      end
    end
  end
end
