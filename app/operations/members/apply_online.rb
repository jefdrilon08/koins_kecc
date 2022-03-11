module Members
  class ApplyOnline
    attr_accessor :reference_number,
                  :online_application

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
          file_document:,
          profile_picture:,
          agree_to_terms:
        )

      @first_name       = first_name
      @middle_name      = middle_name
      @last_name        = last_name
      @gender           = gender
      @date_of_birth    = date_of_birth
      @email            = email
      @mobile_number    = mobile_number
      @address_region   = address_region
      @address_province = address_province
      @address_city     = address_city
      @address_street   = address_street
      @file_document    = file_document
      @profile_picture  = profile_picture
      @agree_to_terms   = agree_to_terms

      @reference_number = SecureRandom.hex(3).upcase
    end

    def execute!
      @online_application = OnlineApplication.new(
                              first_name:         @first_name.upcase,
                              middle_name:        @middle_name.upcase,
                              last_name:          @last_name.upcase,
                              gender:             @gender,
                              date_of_birth:      @date_of_birth,
                              email:              @email,
                              mobile_number:      @mobile_number,
                              reference_number:   @reference_number,
                              agreed_to_dp_terms: true
                            )

      # Form data with default values except for address
      data = {
        is_experienced_with_microfinance: false,
        previous_mfi_experience: "",
        mothers_first_name: "",
        mothers_middle_name: "",
        mothers_last_name: "",
        address: {
          street: @address_street,
          district: @address_district,
          city: @address_city,
          province: @address_province,
          region: @address_region
        },
        spouse: {
          first_name: "",
          middle_name: "",
          last_name: "",
          date_of_birth: "",
          occupation: ""
        },
        government_identification_numbers: {
          sss_number: "",
          pag_ibig_number: "",
          phil_health_number: "",
          tin_number: ""
        },
        num_children_elementary: 0,
        num_children_high_school: 0,
        num_children_college: 0,
        num_children: 0,
        reason_for_joining: "",
        housing: {
          type: "",
          num_months: 0,
          num_years: 0
        },
        banks: [],
        legal_dependents: [],
        beneficiaries: []
      }

      online_application.data = data

      # Process profile picture
      if @profile_picture.present?
        decoded_data = Base64.decode64(@profile_picture.split(',')[1])

        @online_application.profile_picture = { 
          io: StringIO.new(decoded_data),
          content_type: 'image/jpeg',
          filename: 'image.jpg'
        }
      end

      # files
      @online_application.online_application_documents.build(
        file_name: "OTHERFILE",
        file: @file_document
      )

      @online_application.save!
    end
  end
end
