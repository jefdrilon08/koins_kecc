module Api
  module V1
    class BillingsController < ApplicationController
      before_action :authenticate_user!

      def fetch
        billing = Billing.find(params[:id])

        render json: billing
      end

      def toggle_attendance
        billing = Billing.find(params[:id])
        data    = billing.data.with_indifferent_access

        data[:records].each_with_index do |o, i|
          if o[:member][:id] == params[:member_id]
            data[:records][i][:attendance]  = !data[:records][i][:attendance]
          end
        end

        billing.update!(
          data: data
        )
        
        render json: billing
      end

      def modify_transaction_record
        billing             = Billing.where(id: params[:id]).first
        current_transaction = params[:current_transaction]
        current_member      = params[:current_member]

        config  = {
          billing: billing,
          current_transaction: current_transaction,
          current_member: current_member,
          user: current_user
        }

        errors  = ::Billings::ValidateModifyTransactionRecord.new(
                    config: config
                  ).execute!

        if errors[:messages].size > 0
          render json: { errors: errors }, status: 400
        else
          billing = ::Billings::ModifyTransactionRecord.new(
                      config: config
                    ).execute!

          render json: billing
        end
      end

      def create
        collection_date = params[:collection_date].try(:to_date)
        branch_id       = params[:branch_id]
        center_id       = params[:center_id]

        config  = {
          collection_date: collection_date,
          branch_id: branch_id,
          center_id: center_id,
          user: current_user
        }

        errors  = ::Billings::ValidateCreateBilling.new(
                    config: config
                  ).execute!

        if errors[:full_messages].size > 0
          render json: errors, status: 400
        else
          billing = ::Billings::CreateBilling.new(
                      config: config
                    ).execute!

          render json: { id: billing.id }
        end
      end
    end
  end
end
