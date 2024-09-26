class AdminAddressController < ApplicationController
  before_action :authenticate_user!
  
  def upload
    file              = params[:file]
    config = {
      file: file
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
      @admin_address = ::Administration::AdministrationAddress::LoadAdminAddressFromCsvFile.new(config: config).execute!
      flash[:success] = "Successfully uploaded region."
      redirect_to administration_admin_address_index_path(@admin_address)

    end
  end

end
