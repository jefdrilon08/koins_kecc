module Members
  class ValidateReinstatement
    def initialize(member:, reinstatement_date:, date_stop:)
      @member             = member
      @reinstatement_date = reinstatement_date
      @date_stop          = date_stop
      @errors             = []
    end

    def execute!
      @errors
    end
  end
end