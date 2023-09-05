module Members
  class UpdateRecognitionDate
    def initialize(member:, recognition_date:)
      @member              = member
      @recognition_date    = recognition_date
      @member_data         = @member.data.with_indifferent_access

    
      @member_data[:recognition_date]
    end

    def execute!
      @member_data[:recognition_date] = @recognition_date
      @member.update!(data: @member_data)
    end
  end
end
