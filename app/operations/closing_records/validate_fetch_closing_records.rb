module ClosingRecords
  class ValidateFetchClosingRecords
    attr_accessor :errors,
                  :branch,
                  :closing_date

    def initialize(branch:, closing_date:)
      @branch       = branch
      @closing_date = closing_date

      @errors = []
    end

    def execute!
      if @branch.blank?
        @errors << "Branch required"
      end

      if @closing_date.blank?
        @errors << "Closing date required"
      end

      @errors
    end
  end
end
