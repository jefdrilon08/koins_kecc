module Api
  module V1
    class CommissionCollectionsController < ApplicationController
      before_action :authenticate_user!

      def fetch
        commission_collection  = CommissionCollection.find(params[:id])

        data  = {
          id: commission_collection.id,
          meta: commission_collection.meta,
          data: commission_collection.data
        }

        render json:  data
      end

      def approve
        commission_collection  = CommissionCollection.find(params[:id])

        config  = {
          commission_collection: commission_collection,
          user: current_user
        }

        errors  = ::CommissionCollections::ValidateApprove.new(
                    config: config
                  ).execute!

        if errors[:messages].size == 0
          commission_collection.update!(status: "processing")

          # Start job
          args = {
            commission_collection_id: commission_collection.id,
            user_id: current_user.id
          }

          # ProcessApproveInsuranceMonthlyClosingCollection.perform_later(args)
          ProcessApproveCommissionCollection.perform_later(args)

          render json: { id: commission_collection.id }
        else
          render json: errors, status: 400
        end
      end

      def update
        commission_collection  = CommissionCollection.find(params[:id])
        
        commission_collection.update!(
          status: "processing"
        )

        args  = {
          user_id: current_user.id,
          branch_id: branch.id,
          commission_collection_id: commission_collection.id
        }

        # Start job
        # ProcessMonthlyClosingCollection.perform_later(args)
        ProcessCommissionCollection.perform_later(args)

        render json: { id: commission_collection.id }
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
