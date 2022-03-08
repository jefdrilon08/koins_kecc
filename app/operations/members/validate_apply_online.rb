module Members
  class ValidateApplyOnline
    attr_accessor :errors

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

      @errors = {
        first_name:       "",
        middle_name:      "",
        last_name:        "",
        gender:           "",
        date_of_birth:    "",
        email:            "",
        mobile_number:    "",
        address_region:   "",
        address_province: "",
        address_city:     "",
        address_street:   "",
        agree_to_terms:   ""
      }
    end

    def execute!
      if @first_name.blank?
        @errors[:first_name] = "first name required"
      end
      
      if @middle_name.blank?
        @errors[:middle_name] = "middle name required"
      end

      if @last_name.blank?
        @errors[:last_name] = "last name required"
      end

      if @gender.blank?
        @errors[:gender] = "gender required"
      end

      if @date_of_birth.blank?
        @errors[:date_of_birth] = "date of birth required"
      end

      if @mobile_number.blank?
        @errors[:mobile_number] = "mobile number required"
      elsif @mobile_number.size != 13
        @errors[:mobile_number] = "invalid mobile number (format: xxxxxxxxx)"
      end

      if @address_region.blank?
        @errors[:address_region] = "region required"
      end

      if @address_province.blank?
        @errors[:address_province] = "province required"
      end

      if @address_city.blank?
        @errors[:address_city] = "city required"
      end

      if @address_street.blank?
        @errors[:address_street] = "street required"
      end

      if @file_document.blank?
        @errors[:file_document] = "document required"
      end

      if @profile_picture.blank?
        @errors[:profile_picture] = "profile picture required"
      end

      if not @agree_to_terms
        @errors[:agree_to_terms] = "must agree to terms"
      end
    end
  end
end
