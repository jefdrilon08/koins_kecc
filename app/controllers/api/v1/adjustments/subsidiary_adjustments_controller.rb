module Api
  module V1
    module Adjustments
      class SubsidiaryAdjustmentsController < ApplicationController
        before_action :authenticate_user!

        def create
          branch  = Branch.where(id: params[:branch_id]).first

          config  = {
            branch: branch,
            user: current_user
          }

          errors  = ::Adjustments::SubsidiaryAdjustments::ValidateCreate.new(
                      config: config
                    ).execute!

          if errors[:messages].size > 0
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
