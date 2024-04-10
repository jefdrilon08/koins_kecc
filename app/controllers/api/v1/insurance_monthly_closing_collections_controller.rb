module Api
  module V1
    class InsuranceMonthlyClosingCollectionsController < ActionController::Base
      before_action :authenticate_user!

      def fetch
        insurance_monthly_closing_collection  = InsuranceMonthlyClosingCollection.find(params[:id])

        data  = {
          id: insurance_monthly_closing_collection.id,
          meta: insurance_monthly_closing_collection.meta,
          closing_date: insurance_monthly_closing_collection.closing_date.strftime("%b %d, %Y"),
          data: insurance_monthly_closing_collection.data
        }

        render json:  data
      end

      def approve
        insurance_monthly_closing_collection  = InsuranceMonthlyClosingCollection.find(params[:id])

        config  = {
          insurance_monthly_closing_collection: insurance_monthly_closing_collection,
          user: current_user
        }

        errors  = ::InsuranceMonthlyClosingCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size == 0
          insurance_monthly_closing_collection.update!(status: "processing")

          # Start job
          args = {
            insurance_monthly_closing_collection_id: insurance_monthly_closing_collection.id,
            user_id: current_user.id
          }

          ProcessApproveInsuranceMonthlyClosingCollection.perform_later(args)

          render json: { id: insurance_monthly_closing_collection.id }
        else
          render json: errors, status: 400
        end
      end

      def update
        insurance_monthly_closing_collection  = InsuranceMonthlyClosingCollection.find(params[:id])
        branch                                = insurance_monthly_closing_collection.branch
        closing_date                          = insurance_monthly_closing_collection.closing_date

        insurance_monthly_closing_collection.update!(
          status: "processing"
        )

        args  = {
          user_id: current_user.id,
          branch_id: branch.id,
          closing_date: closing_date.to_s,
          insurance_monthly_closing_collection_id: insurance_monthly_closing_collection.id
        }

        # Start job
        ProcessMonthlyClosingCollection.perform_later(args)

        render json: { id: insurance_monthly_closing_collection.id }
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

        errors  = ::InsuranceMonthlyClosingCollections::ValidateCreate.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          # Create new record
          insurance_monthly_closing_collection  = InsuranceMonthlyClosingCollection.new(
                                          branch: branch,
                                          closing_date: closing_date,
                                          account_subtype: account_subtype,
                                          status: "processing"
                                        )

          insurance_monthly_closing_collection.save!

          # Arguments for job
          args  = {
            user_id: current_user.id,
            branch_id: branch.id,
            closing_date: closing_date.to_s,
            insurance_monthly_closing_collection_id: insurance_monthly_closing_collection.id
          }

          # Start job
          ProcessInsuranceMonthlyClosingCollection.perform_later(args)

          render json: { id: insurance_monthly_closing_collection.id }
        end
      end
    end
  end
end
