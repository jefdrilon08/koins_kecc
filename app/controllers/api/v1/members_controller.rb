module Api
  module V1
    class MembersController < ApiController
      def fetch
        config  = {
          id: params[:id]
        }

        data  = ::Members::Fetch.new(
                  config: config
                ).execute!

        render json: data
      end

      def save
        member_data = params[:member_data]

        config  = {
          member_data: member_data,
          id: params[:id],
          user: current_user
        }

        errors  = ::Members::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 402
        else
          member  = ::Members::Save.new(
                      config: config
                    )

          render json: { id: member.id }
        end
      end

      def save_signature
        member  = Member.find(params[:id])

        member.update!(
          signature_data: params[:signature_data]
        )

        render json: { message: "ok" }
      end

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
