module Api
  module V1
    class MemberAccountValidationsController < ApplicationController
      before_action :authenticate_user!

      def cancel
        member_account_validation = MemberAccountValidation.find(params[:id])
        errors = []

        if ["MIS", "AO", "CM", "FM", "REMOTE-FM", "REMOTE-OM"].include? current_user.roles
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForCancellation.new(
                      member_account_validation: member_account_validation
                    ).execute!

          if errors.size == 0
            member_account_validation  = MemberAccountValidations::CancelmemberAccountValidation.new(
                                              member_account_validation: member_account_validation,
                                              user:  current_user
                                            ).execute!

            render json: { message: "Successfully cancelled Member Account Validation" }
          else
            render json: { message: "Cannot cancel this transaction", errors: errors }, status: 401
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def cancel_member
        member         = Member.where(id: params[:member_id]).first
        member_account_validation_record = MemberAccountValidationRecord.where(id: params[:member_account_validation_record_id]).first
        member_account_validation = MemberAccountValidation.find(params[:id])
        date_cancelled = params[:date_cancelled]
        reason         = params[:reason]
        errors = []

        if ["MIS", "OAS", "REMOTE-OAS", "REMOTE-BK", "AO", "REMOTE-OM"].include? current_user.role
          errors  = MemberAccountValidations::ValidateMemberAccountValidationMemberForCancellation.new(
                      member: member,
                      date_cancelled: date_cancelled,
                      reason:reason,
                    ).execute!

          if errors.size == 0
            member_account_validation  = MemberAccountValidations::CancelMemberToMemberAccountValidation.new(
                                              member_account_validation_id: member_account_validation.id,
                                              member: member.id,
                                              date_cancelled: date_cancelled,
                                              reason:reason, 
                                              user:  current_user
                                            ).execute!

            render json: { message: "Successfully cancelled member to Member Account Validation" }
          else
            render json: { message: "Cannot cancel this transaction", errors: errors }, status: 401
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def check
        member_account_validation = MemberAccountValidation.find(params[:id])
        errors = []

        if ["MIS", "CM", "FM", "REMOTE-FM"].include? current_user.role
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForChecking.new(
                      member_account_validation: member_account_validation
                    ).execute!

          if errors.size == 0
            member_account_validation  = MemberAccountValidations::CheckMemberAccountValidation.new(
                                              member_account_validation: member_account_validation, 
                                              user:  current_user
                                            ).execute!

            render json: { message: "Successfully checked Member Account Validation" }
          else
            render json: { message: "Cannot check this transaction", errors: errors }, status: 401
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def validate
        member_account_validation = MemberAccountValidation.find(params[:id])
        errors = []

        if ["MIS", "REMOTE-OM", "AO"].include? current_user.role
          errors  = MemberAccountValidations::ValidateMemberAccountValidationForValidation.new(
                      member_account_validation: member_account_validation
                    ).execute!

          if errors.size == 0
            member_account_validation  = MemberAccountValidations::ValidateMemberAccountValidation.new(
                                              member_account_validation: member_account_validation, 
                                              user:  current_user
                                              )
          
            render json: { message: "Successfully validated Member Account Validation" }
          else
            render json: { message: "Cannot validate this transaction", errors: errors }, status: 401
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

        if ["MIS", "OAS", "CM", "REMOTE-OAS", "REMOTE-BK"].include? current_user.roles.last
          errors = MemberAccountValidations::ValidateNewMemberAccountValidationTransaction.new(branch_id: branch_id, date_prepared: date_prepared).execute!

          if errors.length == 0
            member_account_validation  = MemberAccountValidations::CreateMemberAccountValidation.new(
                                              branch: Branch.find(branch_id), 
                                              date_prepared: date_prepared, 
                                              prepared_by: prepared_by,
                                              is_remote: nil
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
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end      
      end
      
      def delete_member_account_validation_record
        member_account_validation_record = MemberAccountValidationRecord.find(params[:member_account_validation_record_id])
        member_account_validation = member_account_validation_record.member_account_validation
        member_account_validation_record.destroy!
        member_account_validation.update!(updated_at: Time.now)

        render json: { message: "ok" }
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

        # if errors[:messages].size > 0
        #   render json: { errors: errors }, status: 400
        # else
          member_account_validation_record = MemberAccountValidations::AddMemberToMemberAccountValidation.new(
                                                  config: config
                                                ).execute!

          member_account_validation_record.save!
          render json: member_account_validation_record
        # end
      end

      def approve
        member_account_validation = MemberAccountValidation.find(params[:id])
        errors = []

        if ["MIS", "BK"].include? current_user.role
          errors =  MemberAccountValidations::ValidateMemberAccountValidationForApproval.new(
                      member_account_validation: member_account_validation
                    ).execute!
          if errors.size == 0
            member_account_validation  = MemberAccountValidations::ApproveMemberAccountValidation.new(
                                              member_account_validation: member_account_validation, 
                                              user:  current_user
                                            ).execute!

            render json: { message: "Successfully approved Member Account Validation" }
          else
            render json: { message: "Cannot approve this transaction", errors: errors }, status: 401
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