module Members
  class UpdateRecognitionDate
    def initialize(member:, recognition_date:, status:)
      @member              = member
      @recognition_date    = recognition_date
      @member_data         = @member.data.with_indifferent_access
      @status              = status

    end

    def execute!
      @member_data[:recognition_date] = @recognition_date
      @member.update!(data: @member_data)
      @member.update!(status: @status)
    end
  end
end
