module Api
  class PublicController < ActionController::API
    def status_check
      reference_number = params[:reference_number]

      if reference_number.blank?
        render json: { errors: ["reference_number required"] }, status: :not_found
      else
        online_application = OnlineApplication.find_by_reference_number(reference_number)

        if online_application.blank?
          render json: { errors: ["online application not found"] }, status: :not_found
        else
          render json: { status: online_application.status }
        end
      end
    end
  end
end
