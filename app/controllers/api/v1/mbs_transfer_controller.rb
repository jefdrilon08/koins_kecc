module Api
  module V1
    class MbsTransferController < ActionController::Base
      before_action :authenticate_user!
      
      def create
        branch = Branch.find(params[:branch_id])
        center = Center.find(params[:center_id])

        config = {
          branch: branch,
          center: center,
          current_user: current_user  
        }
        errors = ::MbsTransfer::ValidateCreate.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::MbsTransfer::Create.new(config: config).execute!
          render json: { message: "Done" }
        end
      end

      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }
        errors = ::MbsTransfer::ValidateAddMember.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::MbsTransfer::AddMember.new(config: config).execute!
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
       errors = ::MbsTransfer::ValidateAmount.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::MbsTransfer::UpdateAmount.new(config: config).execute!
          ::MbsTransfer::UpdateTotal.new(config: config).execute!
          ::MbsTransfer::BuildAccountingEntry.new(config: config).execute!
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
        record.update(status: "processing")
        args = {
              data_store: record.id,
              user: current_user.id
            }
        ProcessApproveMbsTransfer.perform_later(args)
        render json: { message: "ok" }
      end

      def delete_member
        data_store = DataStore.find(params[:id])
        member_id = params[:member_id]

        config = {
          data_store_id: data_store.id,
          member_id: member_id
        }
        if data_store.status == "pending"
          ::MbsTransfer::DeleteMember.new(config: config).execute!
          render json: {message: "ok"}
        end
        
      end

    end
  end
end
