module OnlineApplications
  class ValidateRegister < ::Core::Validator
    attr_reader :branch, :center

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
      beneficiaries:,
      branch_id:,
      center_id:
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
      @branch_id                = branch_id
      @center_id                = center_id

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
        beneficiaries:            [],
        branch_id:                [],
        center_id:                []
      }
    end

    def execute!
      if @branch_id.blank?
        @payload[:branch_id] << "required"
      else
        @branch = Branch.find_by_id(@branch_id)

        if @branch.blank?
          @payload[:branch_id] << "not found"
        end
      end

      if @center_id.blank?
        @payload[:center_id] << "required"
      else
        @center = Center.find_by_id(@center_id)

        if @center.blank?
          @payload[:center_id] << "not found"
        end
      end

      if @first_name.blank?
        @payload[:first_name] << "required"
      end

      if @last_name.blank?
        @payload[:last_name] << "required"
      end

      if @gender.blank?
        @payload[:gender] << "required"
      elsif not OnlineApplication::GENDERS.include?(@gender)
        @payload[:gender] << "invalid value"
      end

      if @date_of_birth.blank?
        @payload[:date_of_birth] << "required"
      elsif not @date_of_birth.match(/^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/)
        @payload[:date_of_birth] << "invalid value"
      end

      if @email.blank?
        @payload[:email] << "required"
      elsif (@email =~ URI::MailTo::EMAIL_REGEXP).nil?
        @payload[:email] << "invalid value"
      elsif OnlineApplication.where(email: @email).count > 0 or Member.where(email: @email).count > 0
        @payload[:email] << "duplicate value"
      end

      if @mobile_number.blank?
        @payload[:mobile_number] << "required"
      elsif not @mobile_number.match(/\+639[0-9]{9}$/)
        @payload[:mobile_number] << "invalid value"
      elsif OnlineApplication.where("mobile_number LIKE ?", "%" + @mobile_number.slice(-10..)).count > 0 or Member.where("mobile_number LIKE ?", "%" + @mobile_number.slice(-10..)).count > 0
        # Changed to this to find the same 9xxxxxxxxxx numbers
        @payload[:mobile_number] << "duplicate value"
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

#      if @files.blank?
#        @payload[:files] << "required"
#      end

#      if @profile_picture.blank?
#        @payload[:profile_picture] << "required"
#      end

      if @reason_for_joining.blank?
        @payload[:reason_for_joining] << "required"
      end

      if @sss_number.blank?
        @payload[:sss_number] << "required"
      elsif not @sss_number.match(/^[0-9]{10}$/)
        @payload[:sss_number] << "invalid value"
      end

      if @tin_number.blank?
        @payload[:tin_number] << "required"
      elsif not @tin_number.match(/\d{9,12}$/)
        @payload[:tin_number] << "invalid value"
      end

      if @pag_ibig_number.blank?
        @payload[:pag_ibig_number] << "required"
      elsif not @pag_ibig_number.match(/^\d{12}/)
        @payload[:pag_ibig_number] << "invalid value"
      end

      if @phil_health_number.blank?
        @payload[:phil_health_number] << "required"
      elsif not @phil_health_number.match(/^\d{12}$/)
        @payload[:phil_health_number] << "invalid value"
      end

      count_errors!
    end
  end
end
