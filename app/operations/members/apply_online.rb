module Members
  class ApplyOnline
    attr_accessor :reference_number

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
    end
  end
end
