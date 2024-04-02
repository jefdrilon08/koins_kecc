module Api
  module V1
    class MonthlyClosingCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def fetch
        monthly_closing_collection  = MonthlyClosingCollection.find(params[:id])

        data  = {
          id: monthly_closing_collection.id,
          meta: monthly_closing_collection.meta,
          closing_date: monthly_closing_collection.closing_date.strftime("%b %d, %Y"),
          data: monthly_closing_collection.data
        }

        render json:  data
      end

      def approve
        monthly_closing_collection  = MonthlyClosingCollection.find(params[:id])

        config  = {
          monthly_closing_collection: monthly_closing_collection,
          user: current_user
        }

        errors  = ::MonthlyClosingCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size == 0
          monthly_closing_collection.update!(status: "processing")

          # Start job
          args = {
            monthly_closing_collection_id: monthly_closing_collection.id,
            user_id: current_user.id
          }

          ProcessApproveMonthlyClosingCollection.perform_later(args)

          render json: { id: monthly_closing_collection.id }
        else
          render json: errors, status: 400
        end
      end

      def update
        monthly_closing_collection  = MonthlyClosingCollection.find(params[:id])
        branch                      = monthly_closing_collection.branch
        closing_date                = monthly_closing_collection.closing_date

        monthly_closing_collection.update!(
          status: "processing"
        )

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

      def create
        branch          = Branch.where(id: params[:branch_id]).first
        closing_date    = params[:closing_date].try(:to_date)
        account_subtype = params[:account_subtype]

        config  = {
          branch: branch,
          closing_date: closing_date,
          account_subtype: account_subtype,
          user: current_user
        }

        errors  = ::MonthlyClosingCollections::ValidateCreate.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          # Create new record
          monthly_closing_collection  = MonthlyClosingCollection.new(
                                          branch: branch,
                                          closing_date: closing_date,
                                          account_subtype: account_subtype,
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
