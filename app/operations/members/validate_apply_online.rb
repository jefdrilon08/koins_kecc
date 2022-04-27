module Members
  class ValidateApplyOnline
    attr_accessor :errors,
                  :num_errors

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

      @first_name       = first_name.upcase
      @middle_name      = middle_name.upcase
      @last_name        = last_name.upcase
      @gender           = gender
      @date_of_birth    = date_of_birth
      @email            = email
      @mobile_number    = mobile_number
      @address_region   = address_region
      @address_province = address_province
      @address_city     = address_city
      @address_district = address_district
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
        address_district: "",
        address_street:   "",
        agree_to_terms:   ""
      }

      @num_errors = 0
    end

    def execute!
      if @first_name.blank?
        @errors[:first_name] = "first name required"
        @num_errors += 1
      end
      
      if @middle_name.blank?
        @errors[:middle_name] = "middle name required"
        @num_errors += 1
      end

      if @last_name.blank?
        @errors[:last_name] = "last name required"
        @num_errors += 1
      end
      
      if @first_name.present? and @last_name.present? and @date_of_birth.present?
        @member = ReadOnlyMember.joins(:branch).where(
                  "last_name = ? and first_name = ? and date_of_birth = ?",
                  @last_name, @first_name, @date_of_birth).last
        if @member.present?
          @errors[:agree_to_terms] = "member already exists in #{@member.branch.name} SatO"
          @num_errors += 1
        end
      end

      if @gender.blank?
        @errors[:gender] = "gender required"
        @num_errors += 1
      end

      if @date_of_birth.blank?
        @errors[:date_of_birth] = "date of birth required"
        @num_errors += 1
      end

      if @mobile_number.blank?
        @errors[:mobile_number] = "mobile number required"
        @num_errors += 1
      elsif @mobile_number.size != 13
        @errors[:mobile_number] = "invalid mobile number (format: xxxxxxxxx)"
        @num_errors += 1
      elsif not @mobile_number =~ /\+639[0-9]{9}/
        @errors[:mobile_number] = "invalid format"
        @num_errors += 1
      elsif OnlineApplication.where(status: ["for_verification", "verified", "processed"], mobile_number: @mobile_number).count > 0
        @errors[:mobile_number] = "already taken"
        @num_errors += 1
      end

      if @address_region.blank?
        @errors[:address_region] = "region required"
        @num_errors += 1
      end

      if @address_province.blank?
        @errors[:address_province] = "province required"
        @num_errors += 1
      end

      if @address_city.blank?
        @errors[:address_city] = "city required"
        @num_errors += 1
      end

      if @address_street.blank?
        @errors[:address_street] = "street required"
        @num_errors += 1
      end

      if @address_district.blank?
        @errors[:address_district] = "district required"
        @num_errors += 1
      end

      if @file_document.blank?
        @errors[:file_document] = "document required"
        @num_errors += 1
      end

      if @profile_picture.blank?
        @errors[:profile_picture] = "profile picture required"
        @num_errors += 1
      end

      if not @agree_to_terms
        @errors[:agree_to_terms] = "must agree to terms"
        @num_errors += 1
      end
    end
  end
end
