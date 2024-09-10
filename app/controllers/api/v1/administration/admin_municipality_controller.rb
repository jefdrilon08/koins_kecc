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

                    ::Administration::AdministrationAddress::AddMunicipality.new(config: config).execute!
                end

                def fetch
                    admin_municipality = AdminMunicipality.all();
                    
                    render json: admin_municipality
                end

                  
            end
        end
    end
end
 