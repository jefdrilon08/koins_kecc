module Api
  class OnlineApplicationsController < ::Api::V3::ApplicationController
    def register
      # Required parameters
      first_name          = params[:first_name]
      middle_name         = params[:middle_name]
      last_name           = params[:last_name]
      gender              = params[:gender]
      date_of_birth       = params[:date_of_birth]
      email               = params[:email]
      mobile_number       = params[:mobile_number]
      address_region      = params[:address_region]
      address_province    = params[:address_province]
      address_city        = params[:address_city]
      address_district    = params[:address_district]
      address_street      = params[:address_street]
      reason_for_joining  = params[:reason_for_joining]
      sss_number          = params[:sss_number]
      tin_number          = params[:tin_number]
      pag_ibig_number     = params[:pag_ibig_number]
      phil_health_number  = params[:phil_health_number]
      branch_id           = params[:branch_id]
      center_id           = params[:center_id]

      # File attachments
      files = []
      if params[:file_types].present? and params[:file_files].present?
        params[:file_types].each_with_index do |o, i|
          files << {
            type: params[:file_types][i],
            file: params[:file_files][i]
          }
        end
      end

      profile_picture = params[:profile_picture]

      # Optional parameters
      spouse_last_name      = params[:spouse_last_name]
      spouse_first_name     = params[:spouse_first_name]
      spouse_middle_name    = params[:spouse_middle_name]
      spouse_occupation     = params[:spouse_occupation]
      spouse_date_of_birth  = params[:spouse_date_of_birth]

      housing_type        = params[:housing_type]
      housing_num_years   = params[:housing_num_years].try(:to_i)
      housing_num_months  = params[:housing_num_months].try(:to_i)

      mothers_last_name       = params[:mothers_last_name]
      mothers_first_name      = params[:mothers_first_name]
      previous_mfi_experience = params[:previous_mfi_experience]

      # Arrays
      legal_dependents  = []
      beneficiaries     = []

      validator = ::OnlineApplications::ValidateRegister.new(
        first_name:               first_name,
        middle_name:              middle_name,
        last_name:                last_name,
        gender:                   gender,
        date_of_birth:            date_of_birth,
        email:                    email,
        mobile_number:            mobile_number,
        address_region:           address_region,
        address_province:         address_province,
        address_city:             address_city,
        address_district:         address_district,
        address_street:           address_street,
        reason_for_joining:       reason_for_joining,
        sss_number:               sss_number,
        tin_number:               tin_number,
        pag_ibig_number:          pag_ibig_number,
        phil_health_number:       phil_health_number,
        files:                    files,
        profile_picture:          profile_picture,
        spouse_last_name:         spouse_last_name,
        spouse_first_name:        spouse_first_name,
        spouse_middle_name:       spouse_middle_name,
        spouse_occupation:        spouse_occupation,
        spouse_date_of_birth:     spouse_date_of_birth,
        housing_type:             housing_type,
        housing_num_years:        housing_num_years,
        housing_num_months:       housing_num_months,
        mothers_last_name:        mothers_last_name,
        mothers_first_name:       mothers_first_name,
        previous_mfi_experience:  previous_mfi_experience,
        legal_dependents:         legal_dependents,
        beneficiaries:            beneficiaries,
        branch_id:                branch_id,
        center_id:                center_id
      )

      validator.execute!

      if validator.valid?
        cmd = ::OnlineApplications::Register.new(
          first_name:               first_name,
          middle_name:              middle_name,
          last_name:                last_name,
          gender:                   gender,
          date_of_birth:            date_of_birth,
          email:                    email,
          mobile_number:            mobile_number,
          address_region:           address_region,
          address_province:         address_province,
          address_city:             address_city,
          address_district:         address_district,
          address_street:           address_street,
          reason_for_joining:       reason_for_joining,
          sss_number:               sss_number,
          tin_number:               tin_number,
          pag_ibig_number:          pag_ibig_number,
          phil_health_number:       phil_health_number,
          files:                    files,
          profile_picture:          profile_picture,
          spouse_last_name:         spouse_last_name,
          spouse_first_name:        spouse_first_name,
          spouse_middle_name:       spouse_middle_name,
          spouse_occupation:        spouse_occupation,
          spouse_date_of_birth:     spouse_date_of_birth,
          housing_type:             housing_type,
          housing_num_years:        housing_num_years,
          housing_num_months:       housing_num_months,
          mothers_last_name:        mothers_last_name,
          mothers_first_name:       mothers_first_name,
          previous_mfi_experience:  previous_mfi_experience,
          legal_dependents:         legal_dependents,
          beneficiaries:            beneficiaries,
          branch:                   validator.branch,
          center:                   validator.center
        )

        cmd.execute!

        render json: { reference_number: cmd.online_application.reference_number }
      else
        render json: validator.payload, status: :unprocessable_entity
      end
    end
  end
end
