module Api
  module V1
    class BillingForWriteoffController < ApplicationController
      before_action :authenticate_user!

      def fetch
        record = DataStore.billing_for_writeoff.where(id: params[:id]).first
          if record.blank?
              render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else

            render json: record
          end
      end
      def add_member
        billing_for_writeoff= DataStore.billing_for_writeoff.where(id: params[:id]).first
        member = Member.find(params[:member_id])
        loan_product_id = params[:loan_product_id]
        amount = Loan.where(status: "active", loan_product_id: loan_product_id,member_id: params[:member_id]).pluck(:principal_balance).first


        config = {
          billing_for_writeoff: billing_for_writeoff,
          member: member,
          loan_product_id: loan_product_id,
          amount: amount.to_f.round(2)
          }

        errors = ::BillingForWriteoff::ValidateAddMember.new(config: config).execute!
          if errors[:messages].any?
            render json: errors, status: 400
          else
            ::BillingForWriteoff::AddMember.new(config: config).execute!
            render json: { message: "ok" }
          end
      end



      def approve
       record = DataStore.find(params[:id])
        config = {
          data_store: record,
          user: current_user
        }
        errors = ::BillingForWriteoff::ValidateApprove.new(config: config).execute!
          if errors[:messages].any?
            render json: errors, status: 400
          else
            record.update(status: "processing")
            args = {
              data_store: record.id,
              user: current_user.id
            }

            ProcessApproveBillingForWriteoff.perform_later(args)
             render json: { message: "ok" }
          end
      end

      def update
      end

      def delete_member
        data_store      = DataStore.find(params[:id])
        member_id       = params[:member_id]
        loan_product_id = params[:loan_product_id]

        config = {
          data_store: data_store,
          member_id: member_id,
          loan_id: loan_product_id
        }

        errors = ::BillingForWriteoff::ValidateDeleteMember.new(config: config).execute!
         if errors[:messages].any?
            render json: errors, status: 400
          else
            ::BillingForWriteoff::DeleteMember.new(
              config: config
            ).execute!

            render json: { message: "ok" }
          end
        
      end

      def authenticate_user!
        unless current_user
          Rails.logger.debug "Authentication failed: User not logged in."
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end

      def create
      branch  = Branch.where(id: params[:branch_id]).first
      year = params[:year]

          config  = {
            branch: branch,
            year: year,
            user: current_user
          }
      errors  = ::BillingForWriteoff::ValidateCreate.new(
                      config: config
                    ).execute!
        if errors[:messages].any?
            render json: errors, status: 400
        else
          billing_for_writeoff = ::BillingForWriteoff::Create.new(config: config).execute!

          render json: {id: billing_for_writeoff.id}

        end
      end
    end
  end
end
