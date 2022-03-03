module Api
  module V1
    class CommissionCollectionsController < ApplicationController
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
        category      = params[:category]
        start_date    = params[:start_date].try(:to_date)
        end_date      = params[:end_date].try(:to_date)

        config  = {
          start_date: start_date,
          end_date: end_date,
          category: category,
          user: current_user
        }

        errors  = ::CommissionCollections::ValidateCreate.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: errors, status: 400
        else
          # Create new record
          commission_collection  = CommissionCollection.new(
                                          category: category,
                                          start_date: start_date,
                                          end_date: end_date,
                                          date_prepared: Date.today,
                                          status: "processing"
                                        )

          commission_collection.save!

          # Arguments for job
          args  = {
            user_id: current_user.id,
            category: category,
            start_date: start_date.to_s,
            end_date: end_date.to_s,
            commission_collection_id: commission_collection.id
          }

          # Start job
          ProcessCommissionCollection.perform_later(args)

          render json: { id: commission_collection.id }
        end
      end
    end
  end
end
