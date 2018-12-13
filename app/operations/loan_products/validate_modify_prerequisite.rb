module LoanProducts
  class ValidateModifyPrerequisite < AppValidator
    def initialize(config:)
      super()
    end

    def execute!
      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
