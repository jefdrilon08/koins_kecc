module Api 
    module V1
        module Administration
            class AdminMunicipalityController < ApiController
            before_action :authenticate_user!

                def create 
                    config = {
                        municipality_name: params[:municipality],
                        municipalityid:    params[:municipalityid],
                        province_id:       params[:province_id]
                    }

                    Rails.logger.info "Received config: #{config.inspect}"

                    # puts "@@@@@@@@@@@@@@@@@@@@@@@@@"+config.inspect
                    # # begin
                    ::Administration::AdministrationAddress::AddMunicipality.new(config: config).execute!
                    #     render json: result, status: :created
                    # rescue StandardError => e
                    #     render json: { error: e.message }, status: :internal_server_error
                    # end
                end

                  
            end
        end
    end
end
 