module Api
  module V1
    module Adjustments
      class BatchMoratoriumAdjustmentsController < ActionController::Base
        before_action :authenticate_user!

        def approve
          adjustment_record = AdjustmentRecord.find(params[:id])

          config  = {
            adjustment_record: adjustment_record,
            user: current_user
          }

          errors  = ::Adjustments::BatchMoratoriumAdjustments::ValidateApprove.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            args = {
              id: adjustment_record.id,
              user_id: current_user.id
            }

            adjustment_record.update!(status: "processing")

            ProcessApproveBatchMoratoriumAdjustment.perform_later(args)

            render json: { message: "ok" }
          end
        end

        def destroy
          adjustment_record = AdjustmentRecord.find(params[:id])

          config  = {
            adjustment_record: adjustment_record,
            user: current_user
          }

          errors  = ::Adjustments::BatchMoratoriumAdjustments::ValidateDestroy.new(
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
          branch            = Branch.where(id: params[:branch_id]).first
          center            = Center.where(id: params[:center_id]).first
          date_initialized  = params[:date_initialized].try(:to_date)
          number_of_days    = params[:number_of_days].try(:to_i)
          reason            = params[:reason]

          config  = {
            branch: branch,
            center: center,
            user: current_user,
            date_initialized: date_initialized,
            number_of_days: number_of_days,
            reason: reason
          }

          errors  = ::Adjustments::BatchMoratoriumAdjustments::ValidateCreate.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: errors, status: 400
          else
            adjustment_record = ::Adjustments::BatchMoratoriumAdjustments::Create.new(
                                  config: config
                                ).execute!

            render json: { id: adjustment_record.id }
          end
        end
      end
    end
  end
end
