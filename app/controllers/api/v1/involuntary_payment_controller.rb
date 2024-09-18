module Api
  module V1
    class InvoluntaryPaymentController < ActionController::Base
      before_action :authenticate_user!
      
      def create
        branch = Branch.find(params[:branch_id])
        center = Center.find(params[:center_id])

        config = {
          branch: branch,
          center: center,
          current_user: current_user  
        }
        errors = ::InvoluntaryPayment::ValidateCreate.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          billing_for_writeoff_collection = ::InvoluntaryPayment::Create.new(config: config).execute!
        end
      end
      
      def add_member
        config = {
          data_store_id: params[:id],
          member_id: params[:member_id]
        }

        ::InvoluntaryPayment::AddMember.new(config: config).execute!
        ::InvoluntaryPayment::UpdateTotal.new(config: config).execute!
        ::InvoluntaryPayment::BuildAccountingEntry.new(config: config).execute!
        render json: { message: "Done" }
      end

      def update_amount
        config = {
          data_store_id: params[:id],
          loan_id: params[:loan_id],
          payment_amount: params[:payment_amount],
          member_id: params[:member_id]
        }
        errors = ::InvoluntaryPayment::ValidateAmount.new(config: config).execute!
        if errors[:messages].any?
          render json: errors, status: 400
        else
          ::InvoluntaryPayment::UpdateAmount.new(config: config).execute!
          ::InvoluntaryPayment::UpdateTotal.new(config: config).execute!
          ::InvoluntaryPayment::BuildAccountingEntry.new(config: config).execute!
          render json: { message: "Done" }
        end
      end

      def add_book_type
          data_store_id = params[:id]
          txtBt    =  params[:txtBookType]
          ab = DataStore.find(data_store_id)
          if txtBt == ""
          else
            ab.data['accounting_entry']['book'] = txtBt
            ab.save!
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

      def add_or
        data_store_id     = params[:id]
        txtOR    =  params[:txtOR]
        
        data_store = DataStore.find(data_store_id)
        data_store.data['accounting_entry']['data']['or_number'] = txtOR
        data_store.save!
        render json: { message: "Done" }
      end

      def add_si
        data_store_id     = params[:id]
        txtSI    =  params[:txtSI]
        
        data_store = DataStore.find(data_store_id)
        data_store.data['accounting_entry']['data']['si_number'] = txtSI
        data_store.save!
        render json: { message: "Done" }
      end
        
      def approve
        record = DataStore.find(params[:id])
        config = {
          data_store: record.id,
          user: current_user.id
        } 
        args = {
          data_store: record.id,
          user: current_user.id
        }
        record.update(status: "processing")
        ProcessApproveInvoluntaryPayment.perform_later(args)
        render json: { message: "ok" }
      end
      

    end
  end
end
