module Api
  module V1
    class MembersController < ApiController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def register
        member  = Member.where(id: params[:id]).first

        config  = {
          user: current_user,
          member: member
        }

        errors  = ::Epassbook::ValidateRegister.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          cmd = ::Epassbook::Register.new(member: member)

          cmd.execute!

          if cmd.success?
            ActivityLog.create!(
              content: "#{current_user.full_name} registered #{member.full_name} to MyKoins",
              activity_type: "modification",
              data: {
                user_id: current_user.id,
                member_id: member.id
              }
            )

            render json: { message: "ok" }
          else
            render json: { errors: { full_messages: cmd.errors } }, status: 400
          end
        end
      end

      def delete_signature
        member  = Member.where(id: params[:id]).first

        config  = {
          user: current_user,
          member: member
        }

        errors  = ::Members::ValidateDeleteSignature.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          member_full_name  = member.full_name
          member_id         = member.id

          member.signature_file.purge

          ActivityLog.create!(
            content: "#{current_user.full_name} deleted #{member_full_name}'s signature",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end

      def delete_profile_picture
        member  = Member.where(id: params[:id]).first

        config  = {
          user: current_user,
          member: member
        }

        errors  = ::Members::ValidateDeleteProfilePicture.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          member_full_name  = member.full_name
          member_id         = member.id

          member.profile_picture.purge

          ActivityLog.create!(
            content: "#{current_user.full_name} deleted #{member_full_name}'s profile picture",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end

      def upload_signature
        member  = Member.where(id: params[:id]).first
        files   = params[:files]

        config  = {
          user: current_user,
          files: files,
          member: member
        }

        errors  = ::Members::ValidateUploadSignature.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          # Upload code
          member.update!(signature_file: config[:files][0])

          member_full_name  = member.full_name
          member_id         = member.id

          ActivityLog.create!(
            content: "#{current_user.full_name} uploaded #{member_full_name}'s signature",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end

      def upload_profile_picture
        member  = Member.where(id: params[:id]).first
        files   = params[:files]

        config  = {
          user: current_user,
          files: files,
          member: member
        }

        errors  = ::Members::ValidateUploadProfilePicture.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          # Upload code
          member.update!(profile_picture: config[:files][0])

          render json: { message: "ok" }
        end
      end

      def restore
        member  = Member.where(id: params[:id]).first

        config  = {
          user: current_user,
          member: member
        }

        errors  = ::Members::ValidateRestore.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Members::Restore.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def process_resignation
        data  = JSON.parse(params[:data]).to_h.with_indifferent_access

        config  = {
          data: data,
          user: current_user
        }

        errors  = ::Members::ValidateProcessResignation.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::Members::ProcessResignation.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def fetch_resignation_details
        member  = Member.find(params[:id])

        config  = {
          member: member,
          user: current_user
        }

        errors  = ::Members::ValidateFetchResignationDetails.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          data  = ::Members::FetchResignationDetails.new(
                    config: config
                  ).execute!

          render json: data
        end
      end

      def unlock
        member  = Member.find(params[:id])
        
        config  = {
          member: member,
          user: current_user
        }

        errors  = ::Members::ValidateUnlock.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          member_id         = member.id
          member_full_name  = member.full_name

          member.update!(modifiable: true)

          ActivityLog.create!(
            content: "#{current_user.full_name} unlocked member #{member_full_name}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end

      def delete
        member  = Member.find(params[:id])
        
        config  = {
          member: member,
          user: current_user
        }

        errors  = ::Members::ValidateDelete.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          member_id         = member.id
          member_full_name  = member.full_name

          ::Members::Delete.new(
            config: config
          ).execute!

          ActivityLog.create!(
            content: "#{current_user.full_name} deleted member #{member_full_name}",
            activity_type: "deletion",
            data: {
              user_id: current_user.id,
              member_id: member_id
            }
          )

          render json: { message: "ok" }
        end
      end

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

        if errors[:messages].any?
          render json: errors, status: 402
        else
          survey_answer = ::Members::SaveSurveyAnswer.new(
                            config: config
                          ).execute!

          render json: { id: survey_answer.id }
        end
      end

      def member_loan_products
        member      = Member.find(params[:id])
        loans       = Loan.active.where(member_id: member.id)
        paid_loans  = Loan.paid.where(member_id: member.id)

        if loans.size == 0 && paid_loans.size == 0
          loan_products = LoanProduct.entry_point.order("name ASC, is_entry_point ASC").map{ |o| { id: o.id, name: o.name } }
        else
          loan_products = LoanProduct.where.not(id: loans.pluck(:loan_product_id)).order("name ASC, is_entry_point ASC").map{ |o| { id: o.id, name: o.name } }
        end

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

        if errors[:messages].any?
          
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

        if errors[:messages].any?
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
          id: params[:id],
          user: current_user
        }

        errors  = ::Members::ValidateFetch.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 402
        else
          data  = ::Members::Fetch.new(
                    config: config
                  ).execute!

          # Configure branches
          branches  = Branch.where(
                        id: UserBranch.active.where(
                          user_id: current_user.id
                        ).pluck(:branch_id)
                      ).order("name ASC")

          branches_data = []

          branches.each do |o|
            centers = []

            o.centers.order("name ASC").each do |c|
              centers << {
                id: c.id,
                name: c.name
              }
            end

            branches_data << {
              id: o.id,
              name: o.name,
              centers: centers
            }
          end

          data[:branches] = branches_data

          render json: data
        end
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

        if errors[:full_messages].any?
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

      def change_recognition_date
        member            = Member.find(params[:id])
        recognition_date  = params[:recognition_date]

        old_recognition_date  = member.recognition_date

        config  = {
          member: member,
          user: current_user,
          recognition_date: recognition_date
        }

        errors  = ::Members::ValidateChangeRecognitionDate.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          data  = member.data.with_indifferent_access
          
          data[:recognition_date] = recognition_date

          if member.pending? && member.insurance_pending?
            status = "active"
            insurance_status = "dormant"
          else
            status = member.status
            insurance_status = member.status
          end

          if member.identification_number.present?
            identification_number = member.identification_number
          else
            identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                              member: member
                                              ).execute!

            c = member.branch.try(:member_counter) || 0
            member.branch.update(member_counter: c + 1)
          end

          member.update!(
            data: data,
            status: status,
            insurance_status: insurance_status,
            identification_number: identification_number,
            modifiable: nil
          )

          ActivityLog.create!(
            content: "#{current_user.full_name} modified member #{member.full_name}'s recognition_date from #{old_recognition_date} to #{recognition_date}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member.id,
              old_recognition_date: old_recognition_date,
              recognition_date: recognition_date
            }
          )

          render json: { id: member.id }
        end
      end

      def change_member_type
        member      = Member.find(params[:id])
        member_type = params[:member_type]

        old_member_type = member.member_type

        config  = {
          member: member,
          user: current_user,
          member_type: member_type
        }

        errors  = ::Members::ValidateChangeMemberType.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          member.update!(member_type: member_type, modifiable: nil)

          ActivityLog.create!(
            content: "#{current_user.full_name} modified member #{member.full_name}'s member_type from #{old_member_type} to #{member_type}",
            activity_type: "modification",
            data: {
              user_id: current_user.id,
              member_id: member.id,
              old_member_type: old_member_type,
              member_type: member_type
            }
          )

          render json: { id: member.id }
        end
      end

      def generate_missing_accounts
        member  = Member.find(params[:id])

        ::Members::GenerateMissingAccounts.new(
          config: {
            member: member
          }
        ).execute!

        render json: { message: "ok" }
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

      def resign
          member        = Member.where(id: params[:member_id]).first
          date_resigned = params[:date_resigned]
          reason        = params[:reason]
          errors        = ::Members::ValidateResign.new(
                            member: member,
                            date_resigned: date_resigned
                          ).execute!

          if errors.size == 0
            ::Members::Resign.new(
              member: member,
              date_resigned: date_resigned,
              reason: reason,
              resigned_by: current_user.full_name
            ).execute!

            render json: { id: member.id }
          else
            render json: { errors: errors }, status: 402
          end
        end


      def generate_access_token
        member  = Member.where(id: params[:id]).first

        if member.blank?
          render json: { errors: ["member not found"] }, status: 400
        else
          if member.access_token.present?
            render json: { errors: ["access_token already present"] }, status: 400
          elsif member.update!(access_token: "#{SecureRandom.hex(32)}")
            render json: { message: "ok" }
          else
            render json: { errors: ["something went wrong"] }, status: 400
          end
        end
      end

    end
  end
end
