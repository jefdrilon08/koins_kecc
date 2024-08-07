module Api 
    module V1
        module Administration
            class AdminProvinceController < ApiController
            before_action :authenticate_user!

                def create 
                    config = {
                        province_name: params[:province_name],
                        provinceid: params[:provinceid],
                        region_id: params[:region_id]
                    }

                    Rails.logger.info "Received config: #{config.inspect}" # Log the received params

                    # puts "@@@@@@@@@@@@@@@@@@@@@@@@@"+config.inspect
                    # # begin
                    ::Administration::AdministrationAddress::AddProvince.new(config: config).execute!
                    #     render json: result, status: :created
                    # rescue StandardError => e
                    #     render json: { error: e.message }, status: :internal_server_error
                    # end
                end

                  
            end
        end
    end
end
 