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
                    ::Administration::AdministrationAddress::AddProvince.new(config: config).execute!
                end

                def fetch
                    admin_province = AdminProvince.all();
                    
                    render json: admin_province
                end
                  
            end
        end
    end
end
 