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
                    
                    Rails.logger.info "Received config: #{config.inspect}" # Log the received params

                    puts "@@@@@@@@@@@@@@@@@@@@@@@@@#{config.inspect}"
                    
                    # begin
                    ::Administration::AdministrationAddress::AddBarangay.new(config: config).execute!
                    # render json: result, status: :created
                    # rescue StandardError => e
                    # render json: { error: e.message }, status: :internal_server_error
                    # end
                end

            end
        end
    end
end
