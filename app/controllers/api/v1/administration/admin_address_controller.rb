module Api 
    module V1
        module Administration
            class AdminAddressController < ApiController
                before_action :authenticate_user!

                def create 
                    config = {
                        region_name: params[:region],
                        regionid: params[:regionid]
                    }
                    begin
                        result = ::Administration::AdministrationAddress::AddRegion.new(config: config).execute!
                        render json: result, status: :created
                    rescue StandardError => e
                        render json: { error: e.message }, status: :internal_server_error
                    end
                end
                  
            end
        end
    end
end
 