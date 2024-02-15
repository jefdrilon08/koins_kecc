module Members
  class ValidateReclassified
    def initialize(member:, is_reclassified:)
      @member             = member
      @is_reclassified    = is_reclassified
      @errors             = []
    end

    def execute!
      if !@is_reclassified.present?
        @errors << "Reclassified is required!"
      end

      @errors
    end
  end
end