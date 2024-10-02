module Api
  module V1
    class AdminAddressesController < ApiController
      before_action :authenticate_user!, except: [:process_admin_address_file]
      def process_admin_address_file
        actual_url  = params[:actual_url]

        ProcessAdminAddressFile.perform_later({
          actual_url: actual_url
        })

        render json: { message: "ok" }
      end
    end
  end
end
