module OnlineApplications
  class Register
    attr_reader :online_application

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
      branch:,
      center:
    )
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
      @branch                   = branch
      @center                   = center
    end

    def execute!
      data = {
        address: {
          street:   @address_street,
          district: @address_district,
          city:     @address_city,
          region:   @address_region,
          province: @address_province
        },
        government_identification_numbers: {
          sss_number:       @sss_number,
          phil_health_number: @phil_health_number,
          pag_ibig_number:  @pag_ibig_number,
          tin_number:       @tin_number
        },
        spouse: {
          first_name: @spouse_first_name,
          middle_name: @spouse_middle_name,
          last_name: @spouse_last_name,
          date_of_birth: @spouse_date_of_birth,
          occupation: @spouse_occupation
        }
      }

      @online_application = OnlineApplication.new(
        first_name:     @first_name,
        middle_name:    @middle_name,
        last_name:      @last_name,
        gender:         @gender,
        date_of_birth:  @date_of_birth,
        civil_status:   @civil_status,
        mobile_number:  @mobile_number,
        branch:         @branch,
        center:         @center,
        email:          @email,
        data:           data
      )

      @online_application.save!

      @online_application
    end
  end
end
