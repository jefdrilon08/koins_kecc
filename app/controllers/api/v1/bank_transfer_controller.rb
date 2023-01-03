module Api
  module V1
    class BankTransferController < ApplicationController
      before_action :authenticate_user!
      
      def create
        config = {
          bank_name:  params[:bank_name],
          amount:     params[:amount],
          transfer:   params[:transfer],
          accounting: params[:accounting]
        }
          ::BankTransfers::Create.new(config:config).execute!
      end

      def create_channel
        config = {
          transfer_name: params[:transfer_name],
          code:          params[:code]
        }
          ::BankTransfers::CreateChannel.new(config:config).execute!
      end

    end
  end
end