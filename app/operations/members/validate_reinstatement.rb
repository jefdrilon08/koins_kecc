module Members
  class ValidateReinstatement
    def initialize(member:, reinstatement_date:)
      @member             = member
      @reinstatement_date = reinstatement_date
      @errors             = []
    end

    def execute!
      if !@reinstatement_date.present?
        @errors << "Reinstatement date required!"
      end

      @errors
    end
  end
end