module Members
  class ValidateRecognitionDate
    def initialize(member:, recognition_date:)
      @member             = member
      @recognition_date = recognition_date
      @errors             = []
    end

    def execute!
      if !@recognition_date.present?
        @errors << "Recognition_date Date required!"
      end

      @errors
    end
  end
end