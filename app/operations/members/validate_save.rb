module Members
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]
    end

    def execute!
      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
