module MonthlyClosingCollections
  class ValidateCreate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @closing_date = @config[:closing_date]
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
