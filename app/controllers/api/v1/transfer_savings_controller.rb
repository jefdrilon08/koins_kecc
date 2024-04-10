module Api
  module V1
    class TransferSavingsController < ActionController::Base
      before_action :authenticate_user!

      def create
       
        branch_id = params[:branch_id]

        config = {
          branch_id: branch_id,
          user: current_user
        }

        errors = ::TransferSavings::ValidateTransferSavings.new(config: config).execute!
        if errors[:full_messages].any?
          render json: errors, status: 400
        
        else
          transfer_savings = ::TransferSavings::SaveTransferSavings.new(config: config).execute!
          transfer_savings.update(status: "processing")
          
          args = {
            transfer_savings: transfer_savings.id,
            user: current_user.id
          }
          ProcessGenerateTransferSavingsRecord.perform_later(args)

          render json: {message: "ok"}
        end
      end
      
      def fetch
        record = TransferSavingsRecord.find(params[:id])

        render json: record
      end
      
      def approved
        transfer_savings_record = TransferSavingsRecord.find(params[:id])
        config = {
          transfer_savings_record: transfer_savings_record.id,
          user: current_user.id
        }
        errors = ::TransferSavings::ValidateApprove.new(config: config).execute!

        if errors[:messages].any?
          render json: errors, status: 400
         
        else
          transfer_savings_record.update(status: "processing")
          args = {
            transfer_savings_record: transfer_savings_record.id,
            user: current_user.id
          }

          ProcessApproveTransferSavings.perform_later(args)
          render json: {message: "ok"}
        end
      end

    end
  end
end
