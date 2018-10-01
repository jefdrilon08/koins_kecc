module Api
  module V1
    class MembersController < ApiController
      def index
        members = Member.all

        data  = []

        members.each do |o|
          data << {
            id: o.id,
            name: o.full_name
          }
        end

        render json: { members: data }
      end
    end
  end
end
