module Api
  module V1
    class TransferMemberRecordsController < ApplicationController
      before_action :authenticate_user!

      def create
      
        transaction_date = Date.today
        branch_id = params[:branch_id]
        branch_id_to_transfer = params[:branch_id_to_transfer]

        config = {
          branch_id: branch_id,
          branch_id_to_transfer: branch_id_to_transfer,
          user: current_user
        }
        errors = ::TransferMemberRecords::ValidateTransferMemberRecords.new(config: config).execute!

          if errors[:full_messages].any?
            render json: errors, status: 400
          else
            raise "hi".inspect
          end

      end

    end
  end
end
