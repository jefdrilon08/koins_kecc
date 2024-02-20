module Api
  module V1
    module Adjustments
      class SubsidiaryAdjustmentsController < ActionController::Base
        before_action :authenticate_user!

        def update_accounting_entry_particular
          adjustment_record = AdjustmentRecord.subsidiary.where(id: params[:id]).first
          particular        = params[:particular]

          config  = {
            adjustment_record: adjustment_record,
            user: current_user,
            particular: params[:particular]
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateUpdateAccountingEntryParticular.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Adjustments::SubsidiaryAdjustments::UpdateAccountingEntryParticular.new(
              config: config
            ).execute!

            render json: { message: "ok" }
          end
        end

        def add_accounting_code
          adjustment_record = AdjustmentRecord.subsidiary.where(id: params[:id]).first
          accounting_code   = AccountingCode.where(id: params[:accounting_code_id]).first
          amount            = params[:amount].try(:to_f)
          post_type         = params[:post_type]

          config  = {
            adjustment_record: adjustment_record,
            accounting_code: accounting_code,
            amount: amount,
            post_type: post_type,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateAddAccountingCode.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Adjustments::SubsidiaryAdjustments::AddAccountingCode.new(
              config: config
            ).execute!
          end
        end

        def delete_accounting_code
          adjustment_record = AdjustmentRecord.subsidiary.where(id: params[:id]).first
          accounting_code   = AccountingCode.where(id: params[:accounting_code_id]).first
          post_type         = params[:post_type]

          config  = {
            adjustment_record: adjustment_record,
            accounting_code: accounting_code,
            post_type: post_type,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateDeleteAccountingCode.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Adjustments::SubsidiaryAdjustments::DeleteAccountingCode.new(
              config: config
            ).execute!
          end
        end

        def delete_member
          adjustment_record = AdjustmentRecord.subsidiary.where(id: params[:id]).first
          member_account    = MemberAccount.where(id: params[:member_account_id]).first

          config  = {
            adjustment_record: adjustment_record,
            member_account: member_account,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateDeleteMember.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Adjustments::SubsidiaryAdjustments::DeleteMember.new(
              config: config
            ).execute!

            render json: { message: "ok" }
          end
        end
        def print
          raise "Helloworld".inspect
        end
        def add_member
          adjustment_record = AdjustmentRecord.subsidiary.where(id: params[:id]).first
          member            = Member.where(id: params[:member_id]).first
          account_subtype   = params[:account_subtype]
          adjustment        = params[:adjustment]
          amount            = params[:amount]
          member_account    = MemberAccount.where(
                                member_id: member.try(:id),
                                account_subtype: account_subtype
                              ).first

          config  = {
            adjustment_record: adjustment_record,
            member: member,
            account_subtype: account_subtype,
            adjustment: adjustment,
            member_account: member_account,
            amount: amount,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateAddMember.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::Adjustments::SubsidiaryAdjustments::AddMember.new(
              config: config
            ).execute!

            render json: { message: "ok" }
          end
        end

        def approve
          adjustment_record = AdjustmentRecord.find(params[:id])

          config  = {
            adjustment_record: adjustment_record,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateApprove.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
          
            adjustment_record.update!(status: "processing")

            ProcessApproveSubsidiaryAdjustment.perform_later({

              adjustment_record: adjustment_record.id,
              user_id: current_user.id
            })  

            #::Adjustments::SubsidiaryAdjustments::Approve.new(
            #  config: config
            #).execute!

            render json: { message: "ok" }
          end
        end

        def destroy
          adjustment_record = AdjustmentRecord.find(params[:id])

          config  = {
            adjustment_record: adjustment_record,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateDestroy.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            adjustment_record.destroy!

            render json: { message: "ok" }
          end
        end

        def create
          branch  = Branch.where(id: params[:branch_id]).first

          config  = {
            branch: branch,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateCreate.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            adjustment_record = ::Adjustments::SubsidiaryAdjustments::Create.new(
                                  config: config
                                ).execute!

            render json: { id: adjustment_record.id }
          end
        end
      end
    end
  end
end
