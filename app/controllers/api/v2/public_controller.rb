module Api
  module V2
    class PublicController < ApiController
      def apply
        payload = JSON.parse(params[:payload]).with_indifferent_access

        config = {
          first_name:       payload[:first_name],
          middle_name:      payload[:middle_name],
          last_name:        payload[:last_name],
          gender:           payload[:gender],
          date_of_birth:    payload[:date_of_birth],
          civil_status:     payload[:civil_status],
          home_number:      payload[:home_number],
          mobile_number:    payload[:mobile_number],
          place_of_birth:   payload[:place_of_birth],
          religion:         payload[:religion],
          data:             payload[:data],
          file_valid_id:    params[:file_valid_id]
        }

        validator = ::Public::ValidateOnlineApplication.new(
                      config: config
                    )

        validator.execute!

        if validator.errors[:full_messages].size > 0
          render json: { errors: validator.errors[:full_messages] }, status: 403
        else
          cmd = ::Public::SaveOnlineApplication.new(
                  config: config
                )

          cmd.execute!

          render json: { message: "ok", reference_number: cmd.online_application.reference_number }
        end
      end
    end
  end
end
