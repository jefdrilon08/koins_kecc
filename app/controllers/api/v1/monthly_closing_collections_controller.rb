module Api
  module V1
    class MonthlyClosingCollectionsController < ApplicationController
      before_action :authenticate_user!

      def create
        branch          = Branch.where(id: params[:branch_id]).first
        closing_date = params[:closing_date].try(:to_date)

        config  = {
          branch: branch,
          closing_date: closing_date,
          user: current_user
        }

        errors  = ::MonthlyClosingCollections::ValidateCreate.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          monthly_closing_collection  = ::MonthlyClosingCollections::Create.new(
                                          config: config
                                        ).execute!

          render json: { id: monthly_closing_collection.id }
        end
      end
    end
  end
end
