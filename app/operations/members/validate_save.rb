module Members
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]
    end

    def execute!
      # Validate first_name
      if @member_data[:first_name].blank?
        @errors[:messages] << {
          key: "first_name",
          message: "First name required"
        }
      end

      # Validate middle_name
      if @member_data[:middle_name].blank?
        @errors[:messages] << {
          key: "middle_name",
          message: "Middle name required"
        }
      end

      # Validate last_name
      if @member_data[:last_name].blank?
        @errors[:messages] << {
          key: "last_name",
          message: "Last name required"
        }
      end

      # Validate address
      if @member_data[:data][:address][:street].blank?
        @errors[:messages] << {
          key: "address_street",
          message: "Address street required"
        }
      end

      if @member_data[:data][:address][:district].blank?
        @errors[:messages] << {
          key: "address_district",
          message: "Address district required"
        }
      end

      # Validate date of birth
      if @member_data[:date_of_birth].blank?
        @errors[:messages] << {
          key: "date_of_birth",
          message: "Date of birth required"
        }
      end

      # Validate gender
      if @member_data[:gender].blank?
        @errors[:messages] << {
          key: "gender",
          message: "Gender required"
        }
      end

      # Validate civil status
      if @member_data[:civil_status].blank?
        @errors[:messages] << {
          key: "civil_status",
          message: "Civil status required"
        }
      end

      if @member_data[:data][:address][:city].blank?
        @errors[:messages] << {
          key: "address_city",
          message: "Address city required"
        }
      end

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
