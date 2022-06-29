module ClosingRecords
  class ValidateCreate
    attr_accessor :errors,
                  :branch,
                  :record_type,
                  :closing_date

    def initialize(branch:, record_type:, closing_date:)
      @branch       = branch
      @record_type  = record_type
      @closing_date = closing_date

      @errors = []
    end

    def execute!
      if @branch.blank?
        @errors << "Branch required"
      end

      if @record_type.blank?
        @errors << "Record type required"
      end

      if @closing_date.blank?
        @errors << "Closing date required"
      end

      @errors << "Not yet implemented"

      @errors
    end
  end
end
