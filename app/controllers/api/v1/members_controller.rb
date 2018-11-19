module Api
  module V1
    class MembersController < ApiController
      before_action :authenticate_user!

      def fetch_survey_answer
        survey_answer = SurveyAnswer.find(params[:survey_answer_id])

        render json: survey_answer
      end

      def create_survey
        survey  = Survey.where(id: params[:survey_id]).first
        member  = Member.where(id: params[:member_id]).first
        user    = current_user

        config  = {
          survey: survey,
          member: member,
          user: user
        }

        errors  = ::Members::ValidateCreateSurvey.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 402
        else
          survey_answer = ::Members::BuildSurveyAnswer.new(
                            config: config
                          ).execute!

          survey_answer.save!

          render json: { id: survey_answer.id }
        end
      end

      def fetch
        config  = {
          id: params[:id]
        }

        data  = ::Members::Fetch.new(
                  config: config
                ).execute!

        render json: data
      end

      def destroy
        config  = {
          id: params[:id]
        }

        member  = Member.where(id: params[:id]).first

        if member.present? && member.pending?
          member.destroy!

          render json: { message: "ok" }
        else
          render json: { errors: ["member not pending"] }, status: 400
        end
      end

      def save
        member_data = JSON.parse(params[:member_data]).to_h.with_indifferent_access

        config  = {
          member_data: member_data,
          user: current_user
        }

        errors  = ::Members::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          member  = ::Members::Save.new(
                      config: config
                    ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} modified member #{member.full_name}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member.id,
              member_data: member_data
            }
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
