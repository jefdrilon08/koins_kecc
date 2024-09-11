module Api 
    module V1
        module Administration
            class AdminBarangayController < ApiController
                before_action :authenticate_user!

                def create 
                    config = {
                        barangay_name: params[:barangay],
                        barangayid: params[:barangayid],
                        municipality_id: params[:municipality_id]
                    }
                    Rails.logger.info "Received config: #{config.inspect}" 
                    ::Administration::AdministrationAddress::AddBarangay.new(config: config).execute!
                end

                def fetch
                    admin_barangay = AdminBarangay.all();
                    
                    render json: admin_barangay
                end

            end
        end
    end
end
