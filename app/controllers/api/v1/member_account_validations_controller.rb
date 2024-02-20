module Api
  module V1
    class MemberAccountValidationsController < ActionController::Base
      before_action :authenticate_user!

      def cancel
        member_account_validation = MemberAccountValidation.find(params[:id])
        
        config = {
          member_account_validation: member_account_validation,
          user: current_user
        }

        if ["MIS", "AO", "CM", "FM", "REMOTE-FM", "OM"].include? current_user.roles.last
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForCancellation.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            member_account_validation  = MemberAccountValidations::CancelMemberAccountValidation.new(
                                              config: config
                                            ).execute!

            render json: { message: "Successfully cancelled Member Account Validation" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def cancel_member
        member                           = Member.find(params[:member_id])
        member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
        member_account_validation        = MemberAccountValidation.find(params[:id])
        date_cancelled                   = params[:date_cancelled]
        reason                           = params[:reason]
        
        config = {
          member_account_validation: member_account_validation,
          reason: reason,
          date_cancelled: date_cancelled,
          member: member,
          user: current_user
        }

        if ["MIS", "OAS", "REMOTE-OAS", "REMOTE-BK", "REMOTE-FM", "AO", "OM"].include? current_user.roles.last
          errors  = MemberAccountValidations::ValidateMemberAccountValidationMemberForCancellation.new(
                     config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            member_account_validation  = MemberAccountValidations::CancelMemberToMemberAccountValidation.new(
                                              config: config
                                            ).execute!

            render json: { message: "Successfully cancelled member to Member Account Validation" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def add_member
        member_account_validation = MemberAccountValidation.find(params[:id])
        member = Member.find(params[:member_id])
        resignation_date = params[:resignation_date]
        member_classification = params[:member_classification]

        config = {
          member_account_validation: member_account_validation,
          member: member,
          resignation_date: resignation_date,
          member_classification: member_classification,
          user: current_user
        }
        
        errors  = MemberAccountValidations::ValidateMember.new(
                   config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          # if Settings.activate_microinsurance
            member_account_validation_record = MemberAccountValidations::AddMemberToMemberAccountValidationNewCode.new(
                                                  config: config
                                                ).execute!
          # else
          #   member_account_validation_record = MemberAccountValidations::AddMemberToMemberAccountValidation.new(
          #                                         config: config
          #                                       ).execute!
          # end

          member_account_validation_record.save!
          render json: member_account_validation_record
        end
      end

      def check
        member_account_validation = MemberAccountValidation.find(params[:id])

        config = {
          member_account_validation: member_account_validation,
          user: current_user
        }

        if ["MIS", "CM", "FM", "REMOTE-FM"].include? current_user.roles.last
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForChecking.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            member_account_validation  = MemberAccountValidations::CheckMemberAccountValidation.new(
                                              config: config
                                            ).execute!

            render json: { message: "Successfully checked Member Account Validation" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end


      def generate_transaction
        branch_id              = params[:branch_id] 
        date_prepared          = params[:date_prepared]
        prepared_by            = current_user.full_name

        errors = []

        if ["MIS", "OAS", "CM", "REMOTE-OAS", "REMOTE-BK", "REMOTE-FM"].include? current_user.roles.last
          errors = MemberAccountValidations::ValidateNewMemberAccountValidationTransaction.new(branch_id: branch_id, date_prepared: date_prepared).execute!

          if errors.length == 0
            member_account_validation  = MemberAccountValidations::CreateMemberAccountValidation.new(
                                              branch: Branch.find(branch_id), 
                                              date_prepared: date_prepared, 
                                              prepared_by: prepared_by,
                                              is_remote: User::REMOTE_ROLES.include?(current_user.roles.last)
                                            ).execute!

            if member_account_validation.valid?
              member_account_validation.save!
              render json: { messages: ["Successfully created transaction. Redirecting..."], id: member_account_validation.id }
            else
              errors << "Something went wrong"
              member_account_validation.errors.messages.each do |m|
                errors << m
              end
              render json: { errors: errors } , status: 401
            end
          else
            render json: { errors: errors } , status: 401
          end
        else
          errors[:messages] << "Unauthorized to perform this transaction"

          render json: { messages: "Unauthorized", errors: errors }, status: 401
        end      
      end
      
      def delete_member_account_validation_record
        member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
        member_account_validation = member_account_validation_record.member_account_validation
        data = member_account_validation.data.with_indifferent_access
        # member_account_validation.update!(updated_at: Time.now)
        member_account_validation_record.files.purge
        member_account_validation_record.destroy!

        # if Settings.activate_microinsurance
          data[:accounting_entry]  = ::MemberAccountValidations::BuildAccountingEntryNewCode.new(
                                    config: {
                                      branch: member_account_validation.branch,
                                      member_account_validation: member_account_validation,
                                      is_remote: User::REMOTE_ROLES.include?(current_user.roles.last),
                                      user: current_user
                                    }
                                  ).execute!
        ### >> Delete pag okay na ung sa KCOOP
        # else
        #   data[:accounting_entry]  = ::MemberAccountValidations::BuildAccountingEntry.new( 
        #                             config: {
        #                               branch: member_account_validation.branch,
        #                               member_account_validation: member_account_validation,
        #                               is_remote: User::REMOTE_ROLES.include?(current_user.roles.last),
        #                               user: current_user
        #                             }
        #                           ).execute!
        # end
        ### >>

        member_account_validation.data = data
        member_account_validation.save!

        render json: { message: "ok" }
      end

      def validate
        member_account_validation = MemberAccountValidation.find(params[:id])

        config = {
          member_account_validation: member_account_validation,
          user: current_user
        }

        if ["MIS", "OM", "AO"].include? current_user.roles.last
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForValidation.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            member_account_validation  = MemberAccountValidations::ValidateMemberAccountValidation.new(
                                              config: config
                                              ).execute!
          
            render json: { message: "Successfully validated Member Account Validation" }
          end
        else
          errors[:messages] << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def approve
        member_account_validation = MemberAccountValidation.find(params[:id])

        config = {
          member_account_validation: member_account_validation,
          user: current_user
        }

        if ["MIS", "BK", "SBK"].include? current_user.roles.last
          errors =  MemberAccountValidations::ValidateMemberAccountValidationForApproval.new(
                      config: config
                    ).execute!
          
          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            member_account_validation.update!(status: "processing")

            ProcessApproveValidation.perform_later({
              id: member_account_validation.id,
              user_id: current_user.id
            })

            render json: { message: "Successfully approved Member Account Validation", id: member_account_validation.id }
          end
        else
          errors << "Unauthorized to perform this transaction"
          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def reverse
        member_account_validation = MemberAccountValidation.find(params[:id])
        errors = []
        
        if ["MIS", "ACC"].include? current_user.role
          errors = MemberAccountValidations::ValidateMemberAccountValidationForReversal.new(member_account_validation: member_account_validation).execute!
          if errors.size == 0
            MemberAccountValidations::ReverseMemberAccountValidation.new(member_account_validation: member_account_validation, user: current_user).execute!
            render json: { message: "success" }
          else
            render json: { message: "error", errors: errors }, status: 401
          end
        else
          errors << "Unauthorized to perform this transaction"
          render json: { message: "Unauthorized", errors: errors }, status: 401  
        end
      end
    end
  end
end
