module Api
  module V1
    class BillingForWriteoffCollectionController < ApplicationController
      before_action :authenticate_user!
      
      def create
        branch = Branch.find(params[:branch_id])
        center = Center.find(params[:center_id])

        config = {
          branch: branch,
          center: center,
          current_user: current_user  
        }

        billing_for_writeoff_collection = ::BillingForWriteoffCollection::Create.new(config: config).execute!
      end
      
      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }

        ::BillingForWriteoffCollection::AddMember.new(config: config).execute!
        ::BillingForWriteoffCollection::UpdateTotal.new(config: config).execute!
        ::BillingForWriteoffCollection::BuildAccountingEntry.new(config: config).execute!
        render json: { message: "Done" }
      
      end

      def update_amount
        config = {
          data_store_id: params[:id],
          loan_id: params[:loan_id],
          payment_amount: params[:payment_amount],
          member_id: params[:member_id]
        }
        ::BillingForWriteoffCollection::UpdateAmount.new(config: config).execute!
        ::BillingForWriteoffCollection::UpdateTotal.new(config: config).execute!
        ::BillingForWriteoffCollection::BuildAccountingEntry.new(config: config).execute!
        render json: { message: "Done" }

      end

    end
  end
end
