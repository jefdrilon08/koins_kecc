module ShareCapitalSummary
  class ValidateCreate < AppValidator
    def initialize(config:)
      super()

      @config = config
      @branch = @config[:branch]
      @as_of  = @config[:as_of]
    end

    def execute!
      if @branch.nil?
        @errors[:messages] << {
          key: "branch",
          message: "Branch required"
        }
      end
      if @as_of.blank?
        @errors[:messages] << {
          key: "as_of",
          message: "Date required"
        }
      end

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end

