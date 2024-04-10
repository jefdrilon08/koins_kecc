module Api
  module V1
    class AdditionalShareController < ActionController::Base
      before_action :authenticate_user!
      
      def create
        branch = Branch.find(params[:branch_id])
        center = Center.find(params[:center_id])

        config = {
          branch: branch,
          center: center,
          current_user: current_user  
        }
        errors = ::AdditionalShare::ValidateCreate.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::AdditionalShare::Create.new(config: config).execute!
          render json: { message: "Done" }
        end
      end
      
      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }
        errors = ::AdditionalShare::ValidateAddMember.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::AdditionalShare::AddMember.new(config: config).execute!
          render json: { message: "Done" }
        end
      end

      def update_amount
        config = {
          data_store_id: params[:id],
          member_account_id: params[:member_account_id],
          withdraw_amount: params[:withdraw_amount],
          member_id: params[:member_id]
        }
        errors = ::AdditionalShare::ValidateAmount.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::AdditionalShare::UpdateAmount.new(config: config).execute!
          ::AdditionalShare::UpdateTotal.new(config: config).execute!
          ::AdditionalShare::BuildAccountingEntry.new(config: config).execute!
          render json: { message: "Done" }
        end 
      end
      
      def add_particular
        data_store_id     = params[:id]
        txtParticular    =  params[:txtParticular]
        
        data_store = DataStore.find(data_store_id)
        data_store.data['accounting_entry']['particular'] = txtParticular
        data_store.save!
        render json: { message: "Done" }
      end

      def approve
        record = DataStore.find(params[:id])
        config = {
        data_store: record.id,          
        user: current_user.id
        }        
        errors = ::AdditionalShare::ValidateApprove.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          record.update(status: "processing")
            args = {
              data_store: record.id,
              user: current_user.id
            }
          #::AdditionalShare::Approve.new(config: config).execute!
          ProcessApproveAdditionalShare.perform_later(args)
          render json: { message: "ok" }

        end
      end

      def delete_member
        data_store = DataStore.find(params[:id])
        member_id = params[:member_id]

        config = {
          data_store_id: data_store.id,
          member_id: member_id
        }
        if data_store.status == "pending"
          ::AdditionalShare::DeleteMember.new(config: config).execute!
          render json: {message: "ok"}
        end

      end
    end
  end
end 
