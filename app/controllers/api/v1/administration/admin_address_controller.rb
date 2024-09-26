module Api 
    module V1
        module Administration
            class AdminAddressController < ApplicationController
                # before_action :authenticate_user!
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

                def fetch
                    admin_address = AdminAddress.all(); 
                    render json: admin_address
                end

                  
                def upload
                    file              = params[:file]   
                    config = {
                      file: file,
                    }

                    @errors_arr = []
                    CSV.foreach(file.path, headers: true) do |row|
                      # Validate each row
                      errors = ::Administration::AdministrationAddress::ValidateAdminAddressFromCsvFile.new(row: row).execute!

                      if errors[:messages].any?
                        @errors_arr << errors
                      end
                    end

                    if @errors_arr.flatten.size > 20
                      flash[:error] = ["Error, please check your csv."]
                      redirect_to upload_admin_address_index_path
                    elsif @errors_arr.any?
                      flash[:error] = @errors_arr.flatten
                      redirect_to upload_admin_address_index_path
                    else
                      # If no errors, proceed with loading the data
                      @admin_address = ::Administration::AdministrationAddress::LoadAdminAddressFromCsvFile.new(config: config).execute!
                      flash[:success] = "Successfully uploaded region."
                      redirect_to administration_admin_address_index_path(@admin_address)
                    end
                end

            end
        end
    end
end
 