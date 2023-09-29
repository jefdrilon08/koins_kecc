
module Api
  module V1
    class BillingForInvoluntaryController < ApplicationController
      def create
        branch = Branch.find(params[:branch_id])
        
        config = {
          branch: branch,
          current_user: current_user
        }
        errors = ::BillingForInvoluntary::ValidateCreate.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing_for_involuntary = ::BillingForInvoluntary::Create.new(config: config).execute!
        end
      end
      
      def view_details
        data_store = DataStore.find(params[:id])

        config = {
          data_store_id: data_store.id,
          member_id: member_id
        }
      end

      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }

        ::BillingForInvoluntary::AddMember.new(config: config).execute!
       
        render json: { message: "Done" }
      end

      def add_particular
        data_store_id     = params[:id]
        txtParticular    =  params[:txtParticular]
      
        data_store = DataStore.find(data_store_id)
        data_store.data['accounting_entry']['particular'] = txtParticular
        data_store.save!
        render json: { message: "Done" }

      end
      def update_amount
        config = {
          data_store_id: params[:id],
          loan_id: params[:loan_id],
          payment_amount: params[:payment_amount],
          member_id: params[:member_id]
        }
        raise config.inspect
        
      end

    end
  end
end
