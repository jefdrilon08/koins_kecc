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
      
      def delete
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }

        errors = ::BillingForInvoluntary::ValidateDeleteMember.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::BillingForInvoluntary::DeleteMember.new(config: config).execute!
          render json: {message: "DONE"},status: 200
        end
      end
      def view_details
      end

      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }
        errors = ::BillingForInvoluntary::ValidateAddMember.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
        ::BillingForInvoluntary::AddMember.new(config: config).execute!
        render json: { message: "Done" }
        end
      end

      def add_particular_to_transfer_savings
        config = {
          data_store_id: params[:id],
          particular: params[:particular]
        }
        
        errors = ::BillingForInvoluntary::ValidateParticular.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else 
          billing_for_involuntary = ::BillingForInvoluntary::UpdateParticularSavings.new(config: config).execute!
          render json: {message: "success"}
        end

      end

      def add_particular_to_loan_payments
        config = {
          data_store_id: params[:id],
          particular: params[:particular]
        }
        errors = ::BillingForInvoluntary::ValidateParticular.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else 
          billing_for_involuntary = ::BillingForInvoluntary::UpdateParticularLoanPayments.new(config: config).execute!
          render json: {message: "success"}
        end
      end

      def approve
        config = {
          data_store_id: params[:id],
          current_user: current_user.id
        }
        errors = ::BillingForInvoluntary::ValidateApprove.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else 
          
          data_store = DataStore.find(params[:id])
        
          data_store.update(status: "processing")
          
          args = {
            data_store: data_store.id,
            user: current_user.id
          }

          ProcessApprovedCollectionForInvoluntary.perform_later(args)
          render json: { message: "ok" }
        end

      end

    end
  end
end
