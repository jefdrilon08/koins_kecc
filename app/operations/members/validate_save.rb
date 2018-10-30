module Members
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data].with_indifferent_access
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

      # Validate last_name

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
