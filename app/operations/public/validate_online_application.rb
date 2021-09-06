module Public
  class ValidateOnlineApplication < AppValidator
    attr_accessor :errors

    def initialize(config:)
      super()

      @config = config

      @first_name         = @config[:first_name]
      @middle_name        = @config[:middle_name]
      @last_name          = @config[:last_name]
      @gender             = @config[:gender]
      @date_of_birth      = @config[:date_of_birth]
      @civil_status       = @config[:civil_status]
      @home_number        = @config[:home_number]
      @mobile_number      = @config[:mobile_number]
      @place_of_birth     = @config[:place_of_birth]
      @religion           = @config[:religion]
      @legal_dependents   = @config[:data][:legal_dependents] || []
      @beneficiaries      = @config[:data][:beneficiaries] || []
      @file_document      = @config[:file_document]
      @agreed_to_dp_terms = @config[:agreed_to_dp_terms]
      @data               = @config[:data]
    end

    def execute!
      if @file_document.blank?
        @errors[:messages] << {
          key: "file_document",
          message: "file required"
        }
      elsif @file_document.tempfile.size > 8e+6
        @errors[:messages] << {
          key: "file_document",
          message: "file should be less than 8mb"
        }
      elsif !VALID_FILE_TYPES.include?(@file_document.content_type)
        @errors[:messages] << {
          key: "file_document",
          message: "invalid file type for valid id"
        }
      end

      if @agreed_to_dp_terms.blank?
        @errors[:messages] << {
          key: "agreed_to_dp_terms",
          message: "did not agree to data privacy terms"
        }
      end

      if @first_name.blank?
        @errors[:messages] << {
          key: "first_name",
          message: "first_name required"
        }
      end

      if @last_name.blank?
        @errors[:messages] << {
          key: "last_name",
          message: "last_name required"
        }
      end

      if @gender.blank?
        @errors[:messages] << {
          key: "gender",
          message: "gender required"
        }
      end

      if @date_of_birth.blank?
        @errors[:messages] << {
          key: "date_of_birth",
          message: "date_of_birth required"
        }
      end

      if @mobile_number.blank?
        @errors[:messages] << {
          key: "mobile_number",
          message: "mobile number required"
        }
      elsif not @mobile_number =~ /\+639[0-9]{9}/
        @errors[:messages] << {
          key: "mobile_number",
          message: "format for cellphone number should be +639xxxxxxxxx"
        }
      elsif OnlineApplication.where(status: ["for_verification", "verified", "processed"], mobile_number: @mobile_number).count > 0
        @errors[:messages] << {
          key: "mobile_number",
          message: "mobile number already present"
        }
      end

      if @beneficiaries.size <= 0
        @errors[:messages] << {
          key: "beneficiaries",
          message: "beneficiaries required"
        }
      else
        @beneficiaries.each do |o|
          if o[:firstName].blank?
            @errors[:messages] << {
              key: "beneficiary_first_name",
              message: "beneficiary first name required"
            }
          end

          if o[:lastName].blank?
            @errors[:messages] << {
              key: "beneficiary_last_name",
              message: "beneficiary last name required"
            }
          end

          if o[:dateOfBirth].blank?
            @errors[:messages] << {
              key: "beneficiary_date_of_birth",
              message: "beneficiary date of birth required"
            }
          end

          if o[:relationship].blank?
            @errors[:messages] << {
              key: "beneficiary_relationship",
              message: "beneficiary relationship required"
            }
          end
        end
      end

      if @legal_dependents.size <= 0
        @errors[:messages] << {
          key: "legal_dependents",
          message: "legal_dependents required"
        }
      else
        @legal_dependents.each do |o|
          if o[:firstName].blank?
            @errors[:messages] << {
              key: "legal dependent first_name",
              message: "legal dependent first name required"
            }
          end

          if o[:lastName].blank?
            @errors[:messages] << {
              key: "legal_dependent_last_name",
              message: "legal dependent last name required"
            }
          end

          if o[:dateOfBirth].blank?
            @errors[:messages] << {
              key: "legal_dependent_date_of_birth",
              message: "legal dependent date of birth required"
            }
          end
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
