module Api
  module V1
    class CommissionCollectionsController < ActionController::Base
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

      def modify_book
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        book                   = params[:book]

        config  = {
          book: book,
          user: current_user,
          commission_collection: commission_collection,
        }

  
        ::CommissionCollections::ModifyBook.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end

      def add_transaction_fee
        commission_collection = CommissionCollection.where(id: params[:id]).first
        transaction_fee       = params[:transaction_fee].to_f

        config  = {
          transaction_fee: transaction_fee,
          commission_collection: commission_collection,
          user: current_user
        }

        errors  = ::CommissionCollections::ValidateAddTransactionFee.new(
                    config: config
                  ).execute!

        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::CommissionCollections::AddTransactionFee.new(
            config: config
          ).execute!

          render json: { id: commission_collection.id }
        end
      end

      def modify_particular
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        particular   = params[:particular]

        config  = {
          particular: particular,
          commission_collection: commission_collection,
          user: current_user
        }

        ::CommissionCollections::ModifyParticular.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end

      def save_payee
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        payee   = params[:payee]

        config  = {
          payee: payee,
          commission_collection: commission_collection,
          user: current_user
        }

        ::CommissionCollections::SavePayee.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end

      def save_check_number
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        check_number   = params[:check_number]

        config  = {
          check_number: check_number,
          commission_collection: commission_collection,
          user: current_user
        }

        ::CommissionCollections::SaveCheckNumber.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end

      def save_check_voucher_number
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        check_voucher_number   = params[:check_voucher_number]

        config  = {
          check_voucher_number: check_voucher_number,
          commission_collection: commission_collection,
          user: current_user
        }

        ::CommissionCollections::SaveCheckVoucherNumber.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end

      def modify_template
        commission_collection  = CommissionCollection.where(id: params[:id]).first
        template  = params[:template]

        config  = {
          template: template,
          commission_collection: commission_collection,
          user: current_user
        }

      
        ::CommissionCollections::ModifyTemplate.new(
          config: config
        ).execute!

        render json: { id: commission_collection.id }
      end
    end
  end
end
