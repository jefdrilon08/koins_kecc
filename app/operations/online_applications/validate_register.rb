module OnlineApplications
  class ValidateRegister < ::Core::Validator

    def initialize(
      first_name:,
      middle_name:,
      last_name:,
      gender:,
      date_of_birth:,
      email:,
      mobile_number:,
      address_region:,
      address_province:,
      address_city:,
      address_district:,
      address_street:,
      reason_for_joining:,
      sss_number:,
      tin_number:,
      pag_ibig_number:,
      phil_health_number:,
      files:,
      profile_picture:,
      spouse_last_name:,
      spouse_first_name:,
      spouse_middle_name:,
      spouse_occupation:,
      spouse_date_of_birth:,
      housing_type:,
      housing_num_years:,
      housing_num_months:,
      mothers_last_name:,
      mothers_first_name:,
      previous_mfi_experience:,
      legal_dependents:,
      beneficiaries:
    )
      super()

      @first_name               = first_name
      @middle_name              = middle_name
      @last_name                = last_name
      @gender                   = gender
      @date_of_birth            = date_of_birth
      @email                    = email
      @mobile_number            = mobile_number
      @address_region           = address_region
      @address_province         = address_province
      @address_city             = address_city
      @address_district         = address_district
      @address_street           = address_street
      @reason_for_joining       = reason_for_joining
      @sss_number               = sss_number
      @tin_number               = tin_number
      @pag_ibig_number          = pag_ibig_number
      @phil_health_number       = phil_health_number
      @files                    = files
      @profile_picture          = profile_picture
      @spouse_last_name         = spouse_last_name
      @spouse_first_name        = spouse_first_name
      @spouse_middle_name       = spouse_middle_name
      @spouse_occupation        = spouse_occupation
      @spouse_date_of_birth     = spouse_date_of_birth
      @housing_type             = housing_type
      @housing_num_years        = housing_num_years
      @housing_num_months       = housing_num_months
      @mothers_last_name        = mothers_last_name
      @mothers_first_name       = mothers_first_name
      @previous_mfi_experience  = previous_mfi_experience
      @legal_dependents         = legal_dependents
      @beneficiaries            = beneficiaries

      @payload = {
        first_name:               [],
        middle_name:              [],
        last_name:                [],
        gender:                   [],
        date_of_birth:            [],
        email:                    [],
        mobile_number:            [],
        address_region:           [],
        address_province:         [],
        address_city:             [],
        address_district:         [],
        address_street:           [],
        reason_for_joining:       [],
        sss_number:               [],
        tin_number:               [],
        pag_ibig_number:          [],
        phil_health_number:       [],
        files:                    [],
        profile_picture:          [],
        spouse_last_name:         [],
        spouse_first_name:        [],
        spouse_middle_name:       [],
        spouse_occupation:        [],
        spouse_date_of_birth:     [],
        housing_type:             [],
        housing_num_years:        [],
        housing_num_months:       [],
        mothers_last_name:        [],
        mothers_first_name:       [],
        previous_mfi_experience:  [],
        legal_dependents:         [],
        beneficiaries:            []
      }
    end

    def execute!
      if @first_name.blank?
        @payload[:first_name] << "required"
      end

      if @last_name.blank?
        @payload[:last_name] << "required"
      end

      if @gender.blank?
        @payload[:gender] << "required"
      end

      if @date_of_birth.blank?
        @payload[:date_of_birth] << "required"
      end

      if @email.blank?
        @payload[:email] << "required"
      end

      if @mobile_number.blank?
        @payload[:mobile_number] << "required"
      end

      if @address_region.blank?
        @payload[:address_region] << "required"
      end

      if @address_province.blank?
        @payload[:address_province] << "required"
      end

      if @address_city.blank?
        @payload[:address_city] << "required"
      end

      if @address_district.blank?
        @payload[:address_district] << "required"
      end

      if @address_street.blank?
        @payload[:address_street] << "required"
      end

      if @files.blank?
        @payload[:files] << "required"
      end

      if @profile_picture.blank?
        @payload[:profile_picture] << "required"
      end

      if @reason_for_joining.blank?
        @payload[:reason_for_joining] << "required"
      end

      if @sss_number.blank?
        @payload[:sss_number] << "required"
      end

      if @tin_number.blank?
        @payload[:tin_number] << "required"
      end

      if @pag_ibig_number.blank?
        @payload[:pag_ibig_number] << "required"
      end

      if @phil_health_number.blank?
        @payload[:phil_health_number] << "required"
      end

      count_errors!
    end
  end
end
