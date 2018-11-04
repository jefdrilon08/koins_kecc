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

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
