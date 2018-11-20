module Api
  module V1
    class MembersController < ApiController
      before_action :authenticate_user!

      def save_survey_answer
        data          = JSON.parse(params[:data]).to_h.with_indifferent_access
        survey_answer = SurveyAnswer.where(id: params[:id]).first

        config  = {
          data: data,
          survey_answer: survey_answer,
          user: current_user
        }

        errors  = ::Members::ValidateSaveSurveyAnswer.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: errors, status: 402
        else
          survey_answer = ::Members::SaveSurveyAnswer.new(
                            config: config
                          ).execute!

          render json: { id: survey_answer.id }
        end
      end

      def member_loan_products
        member    = Member.find(params[:id])
        loans     = Loan.active_or_pending.where(member_id: member.id)

        loan_products = LoanProduct.where.not(id: loans.pluck(:loan_product_id)).order("name DESC, is_entry_point ASC").map{ |o| { id: o.id, name: o.name } }

        render json: { loan_products: loan_products }
      end

      def member_co_makers
        member    = Member.find(params[:id])
        co_makers = []

        Member.active.where(center_id: member.center.id).where.not(id: member.id).each do |o|
          co_makers << {
            value: o.id,
            label: o.full_name,
            id: o.id,
            first_name: o.first_name,
            middle_name: o.middle_name,
            last_name: o.last_name
          }
        end

        render json: { co_makers: co_makers }
      end

      def delete_survey_answer
        survey_answer = SurveyAnswer.where(id: params[:id]).first

        config  = {
          survey_answer: survey_answer,
          user: current_user
        }

        errors  = ::Members::ValidateDeleteSurveyAnswer.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          
          render json: errors, status: 402
        else
          survey_answer.destroy!

          render json: { message: "ok" }
        end
      end

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
