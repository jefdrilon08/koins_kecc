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
          # Create new record
          monthly_closing_collection  = MonthlyClosingCollection.new(
                                          branch: branch,
                                          closing_date: closing_date,
                                          status: "processing"
                                        )

          monthly_closing_collection.save!

          # Arguments for job
          args  = {
            user_id: current_user.id,
            branch_id: branch.id,
            closing_date: closing_date.to_s,
            monthly_closing_collection_id: monthly_closing_collection.id
          }

          # Start job
          ProcessMonthlyClosingCollection.perform_later(args)

          render json: { id: monthly_closing_collection.id }
        end
      end
    end
  end
end
