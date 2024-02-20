module Api
  module V1
    module Adjustments
      class MoratoriumsController < ActionController::Base
        before_action :authenticate_user!

        def batch_process
          center  = Center.where(id: params[:center_id]).first

          config = {
            center: center,
            user: current_user
          }

          validator = ::Adjustments::Moratoriums::ValidateBatchProcess.new(
                        config: config
                      )

          validator.execute!

          if validator.errors[:messages].any?
            render json: validator.errors, status: 400
          else
            MemberMoratorium.pending.where(
              center_id: center.id
            ).update(
              status: "processing"
            )

            ProcessMemberMoratoriumBatchProcess.perform_later({
              center_id: center.id,
              user_id: current_user.id
            })

            render json: { message: "ok" }
          end
        end

        def process_moratorium
          member_moratorium_id = params[:id]
          member_moratorium    = MemberMoratorium.where(id: params[:id]).first

          config = {
            member_moratorium: member_moratorium,
            user: current_user
          }

          validator = ::Adjustments::Moratoriums::ValidateProcess.new(
                        config: config
                      )

          validator.execute!

          if validator.errors[:messages].any?
            render json: validator.errors, status: 400
          else
            member_moratorium.update!(status: "processing")

            ProcessMemberMoratorium.perform_later({
              id: member_moratorium_id,
              user_id: current_user.id
            })

            render json: { message: "ok" }
          end
        end

        def delete
          moratorium  = MemberMoratorium.find(params[:id])

          if !moratorium.pending?
            raise "Invalid record #{moratorium.id}"
          end

          moratorium.destroy!

          render json: { message: "ok" }
        end

        def create
          branch  = Branch.where(id: params[:branch_id]).first
          center  = Center.where(id: params[:center_id]).first
          member  = Member.where(id: params[:member_id]).first
          loans   = Loan.where(id: params[:loan_ids])
          reason  = params[:reason]

          date_initialized  = params[:date_initialized]
          number_of_days    = params[:number_of_days]

          config = {
            branch: branch,
            center: center,
            member: member,
            date_initialized: date_initialized,
            number_of_days: number_of_days,
            user: current_user,
            loans: loans,
            reason: reason
          }

          validator = ::Adjustments::Moratoriums::ValidateCreate.new(
                        config: config
                      )

          validator.execute!

          if validator.errors[:messages].any?
            render json: validator.errors, status: 400
          else
            record  = ::Adjustments::Moratoriums::Create.new(
                        config: config
                      ).execute!

            render json: { id: record.id }
          end
        end
      end
    end
  end
end
